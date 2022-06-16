class Invoice < ApplicationRecord
  audited
  belongs_to :client, optional: true
  has_many :invoice_inventories, dependent: :destroy
  has_many :inventories, through: :invoice_inventories
  validates_associated :invoice_inventories
  accepts_nested_attributes_for :invoice_inventories, allow_destroy: true
  belongs_to :sales_person, class_name: 'User', optional: true
  has_many :payments, dependent: :destroy
  has_one :invoice_pdf, dependent: :destroy
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables
  has_many :unreads, as: :unreadable, dependent: :destroy

  after_create :create_unread

  def paid?
    payments.where(successful: true).exists?
  end

  def amount_with_tax
    sprintf '%.2f', invoice_inventories.sum{|i| i.amount_with_tax_without_formatting}
  end

  def create_unread
    client.contacts.each do |contact|
      Unread.create(unreadable: self, resourcable: contact)
    end
    # todo: implement unread for users of this company
  end

  def create_pdf
    InvoiceWorker.perform_async(:create_pdf, invoice_id: self.id)
  end

  def send_mail(subject, body)
    InvoiceWorker.perform_async(:send_mail, invoice_id: self.id, subject: subject, body: body)
  end

end
