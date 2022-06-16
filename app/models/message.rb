class Message < ApplicationRecord

  scope :ordered, -> { order(created_at: :desc) }

  belongs_to :messageable, polymorphic: true
  has_many :messages, as: :messageable, dependent: :destroy
  # belongs_to :user
  belongs_to :resourcable, polymorphic: true
  # has_many :documents, as: :documentable, dependent: :destroy
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables

  after_create :broadcast_message

  # TODO: Simplify this logic
  def send_project_message_email(msg_id, user_type)
    @message = Message.find(msg_id)
    if @message.messageable_type == 'Project'
      @project = Project.find(@message.messageable_id)
    elsif @message.messageable_type == 'Ticket'
      @ticket = Ticket.find(@message.messageable_id)
    elsif @message.messageable_type == 'Message'
      msg = Message.find(@message.messageable_id)
      if msg.messageable_type == 'Project'
        @project = msg.messageable
      elsif msg.messageable_type == 'Ticket'
        @ticket = msg.messageable
      end
    end
    @project_users = @project_contacts = @ticket_users = @ticket_contacts = []
    if user_type == 'User'
      if @project
        @project_users = ProjectUser.where(project_id: @project.id)
        @project_contacts = ProjectContact.where(project_id: @project.id)
      elsif @ticket
        @ticket_users = TicketUser.where(ticket_id: @ticket.id)
        @ticket_contacts = TicketContact.where(ticket_id: @ticket.id)
      end
    elsif user_type == "Contact"
      if @project
        @project_users = ProjectUser.where(project_id: @project.id)
        @project_contacts = ProjectContact.where(project_id: @project.id)
      elsif @ticket
        @ticket_users = TicketUser.where(ticket_id: @ticket.id)
        @ticket_contacts = TicketContact.where(ticket_id: @ticket.id)
      end
    end
    @project_users.each do |user|
      # send message mail to project user
      MesssageWorker.perform_async(:send_project_messaage_to_user, msg_id: msg_id, project_id: @project.id, user_id: user.user_id)
    end
    @project_contacts.each do |contact|
      # send message mail to project contact
      MesssageWorker.perform_async(:send_project_messaage_to_contact, msg_id: msg_id, project_id: @project.id, contact_id: contact.contact_id)
    end

    # Notify associated users and contacts in ticket
    if @ticket
      MesssageWorker.perform_async('send_ticket_message_to_associated_user_and_contact', ticket_id: @ticket.id)
    end
  end

  def get_parent_message
    message = self
    while !['Project', 'Ticket'].include?(message.messageable_type)
      message = message.messageable
    end
    message
  end

  def broadcast_message
    ActionCableWorker.perform_async(resource_klass: 'Project', resource_id: get_parent_message.messageable.id) if get_parent_message.messageable
    ActionCableWorker.perform_async(resource_klass: 'Message', resource_id: get_parent_message.id) if get_parent_message
    ActionCableWorker.perform_async(resource_klass: 'Ticket', resource_id: get_parent_message.messageable.id) if get_parent_message.messageable
  end
end
