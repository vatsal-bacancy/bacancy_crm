class Ticket < ApplicationRecord
  include WorkFlows::Observer

  audited
  # TODO: FIXME: We can't eager load this because of order is not working after eager load
  has_one :last_status_audit, -> { reorder(version: :desc).where('audited_changes::text like ?', '%status%') }, as: :auditable, class_name: 'Audited::Audit'

  scope :created_order, -> { order(:created_at) }
  scope :active, -> { where.not(status: INACTIVE_STATUSES) }
  scope :last_30_days, -> { where('created_at > ?', 31.days.ago) }

  belongs_to :owner, class_name: 'User'
  belongs_to :ticketable, polymorphic: true

  # Note: here `lead` and `client` are fake associations, used for searching purpose only by `TicketDatatable`
  belongs_to :lead, -> { where(tickets: { ticketable_type: 'Lead' }).includes(:tickets) }, foreign_key: 'ticketable_id', optional: true
  belongs_to :client, -> { where(tickets: { ticketable_type: 'Client' }).includes(:tickets) }, foreign_key: 'ticketable_id', optional: true

  has_many :ticket_users, dependent: :destroy
  has_many :users, through: :ticket_users
  has_many :ticket_contacts, dependent: :destroy
  has_many :contacts, through: :ticket_contacts

  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables
  has_many :messages, as: :messageable, dependent: :destroy
  has_many :unreads, as: :unreadable, dependent: :destroy

  INACTIVE_STATUSES = ['Close', 'Client Pending']

  def ticketable_company_name
    self.ticketable.company_name
  end

  # Sends Initial ticket mail
  def send_mail
    MesssageWorker.perform_async('send_ticket_mail', ticket_id: self.id)
  end

  def associated_user_and_contact_emails
    self.users.pluck(:email) + self.contacts.pluck(:email) + [self.owner.email]
  end

  # Note: This depends on dynamic fields it could break the application, if deleted
  def sales_agent_name
    if self.ticketable_type == 'Lead'
      self.ticketable.sales__assign__to
    else
      self.ticketable.ipos_agent_name_
    end
  end

  # Late stands for ticket is older than 4 hours after changing status (excluding inactive statuses)
  def late?
    INACTIVE_STATUSES.exclude?(status) && last_status_audit.created_at < 4.hours.ago
  end

  def valid_statuses
    self.class.valid_statuses
  end

  def self.valid_statuses
    klass.fields.find_by(name: 'status').field_picklist_values
  end

  def self.klass
    Klass.find_by(name: 'Ticket')
  end
end
