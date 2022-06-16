class Project < ApplicationRecord
  # acts_as_paranoid
  audited
  belongs_to :user
  # has_many :project_tasks, dependent: :destroy
  belongs_to :client
  # has_many :project_assignees
  # has_many :users, through: :project_assignees
  has_many :messages, as: :messageable, dependent: :destroy
  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  # has_many :project_documents, dependent: :destroy
  has_many :project_contacts, dependent: :destroy
  has_many :contacts, through: :project_contacts
  # accepts_nested_attributes_for :project_assignees, reject_if: :all_blank, allow_destroy: true
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables
  has_many :unreads, as: :unreadable, dependent: :destroy

  def find_project_users(params, project, current_user)
    @invited_project_users = []
    @invited_project_contacts = []

    @project_users = params[:user_ids].present? ? params[:user_ids] : []
    @project_contacts = params[:contact_ids].present? ? params[:contact_ids] : []

    @project_users.each do |user|
      @invited_project_users << User.find(user) #user find
    end

    @project_contacts.each do |contact|
      @invited_project_contacts << Contact.find(contact) #contact find
    end

    self.send_project_user_invitaion(current_user, invited_users: @invited_project_users, project: project)
    self.send_project_contact_invitation(current_user, invited_contact: @invited_project_contacts, project: project)
    @invited_project_users
  end

  def send_project_user_invitaion(current_user, opts={})
    @users = opts[:invited_users]
    @project = opts[:project]
    @users.each do |user|
      @project_user = @project.project_users.find_by(user_id: user.id)
      InvitationWorker.perform_async(:project_user_invitation,  current_user: current_user.id, user_id: user.id,project_id: @project.id, project_user_id: @project_user.id, login_status: true)
    end
  end


  def send_project_contact_invitation(current_user, opts={})
    @contact = opts[:invited_contact]
    @project = opts[:project]
    @contact.each do |contact|
      @project_contact = @project.project_contacts.find_by(contact_id: contact.id)
      # @token = contact.send(:set_reset_password_token)
      InvitationWorker.perform_async(:project_contact_invitation,  current_user: current_user.id, contact_id: contact.id,project_id: @project.id, project_contact_id: @project_contact.id)
    end
  end

  def project_invitation(current_user, opts={})
    current_user = current_user
    user = opts[:user]
    project = opts[:project]
    project_user = opts[:project_user]
    login_status = opts[:login_status]
    token = opts[:token]
    InvitationWorker.perform_async(:project_user_invitation, current_user: current_user.id, user_id: user.id, project_id: project.id, project_user_id: project_user.id, login_status: login_status, token: token)
  end
end
