class Contact < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
  mount_uploader :profile_picture, AttachmentUploader

  has_many :clients ,:through => :lead_client_contacts, :source => :contactable, :source_type => 'Client'
  has_many :leads ,:through => :lead_client_contacts, :source => :contactable, :source_type => 'Lead'
  has_one :lead_client_contact, dependent: :destroy
  has_many :messages, as: :resourcable, dependent: :destroy
  has_many :project_contacts, dependent: :destroy
  has_many :projects, through: :project_contacts
  has_many :ticket_contacts, dependent: :destroy
  has_many :associated_tickets, through: :ticket_contacts, source: :ticket
  has_many :unreads, as: :resourcable, dependent: :destroy
  has_many :directories,as: :resourcable, dependent: :destroy
  has_many :documents, as: :resourcable, dependent: :destroy
  has_many :file_manager_folders, as: :owner, class_name: 'FileManager::Folder', dependent: :destroy
  has_many :file_manager_files, as: :owner, class_name: 'FileManager::File', dependent: :destroy
  has_many :attendees, as: :resourceable, class_name: 'Meetings::Attendee', dependent: :destroy
  before_save :set_fullname

  def send_login_instructions(current_user)
    InvitationWorker.perform_async(:contact_login_instructions, contact_id: id, current_user_id: current_user.id)
  end

  def send_account_setup_instructions(current_user)
    token = set_reset_password_token
    InvitationWorker.perform_async(:contact_account_setup_instructions, contact_id: id, token: token, current_user_id: current_user.id)
  end

  def active?
    encrypted_password != ''
  end

  def system_directory
    Directory.where(directoriable: self.lead_client_contact.contactable).where(name: 'system_dir').first
  end

  def to_polymorphic
    "Contact:#{id}"
  end

  protected

  def password_required?
    return false
  end

  def set_fullname
    self.fullname = "#{first_name} #{last_name}".strip
  end
end
