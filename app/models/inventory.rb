class Inventory < ApplicationRecord

  # Only used for maintaining the inventory status history
  can_go_back_in_time only: [:status], serializer_args: {include: {client_inventory_association: {include: :client}}}

  default_scope -> { order(created_at: :desc) }

  scope :active, -> { where status: STATUSES[:available] }

  belongs_to :inventory_group, optional: true
  belongs_to :user
  belongs_to :subcategory, optional: true
  belongs_to :category, optional: true
  belongs_to :merchant, optional: true
  belongs_to :brand, optional: true
  belongs_to :unit, optional: true
  belongs_to :vendor, optional: true

  has_many :stock_adjustments, dependent: :destroy
  has_many :invoice_inventories, dependent: :destroy
  has_many :invoices, through: :invoice_inventories, dependent: :destroy
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables

  has_one :client_inventory_association, class_name: 'Client::InventoryAssociation', dependent: :destroy

  PERMITTED_PARAMS = %i[id brand_id merchant_id category_id subcategory_id inventory_group_id user_id buy_price sell_price image barcode is_taxable tax sku available_quantity unit_id returnable is_service reorder_level upc ean name _destroy description mpn initial_quantity length width height weight is_saleable sales_description is_purchasable purchase_description is_trackable initial_value status vendor_id purchase_date purchase_order_number mac_address]

  STATUSES = { available: 'Available At iPos Office', assigned_to_client: 'Assigned to Client', sent_to_repair: 'Sent To Repair', damaged: 'Damaged' }

  def image_paths
    documents.present? ? documents.map{|document| document.attachment.url} : ['inv-placeholder.png']
  end

  def unit_label
    unit.try(:messure)
  end

  def recalculate_current_stock
    quantity_to_update = self.stock_adjustments.where(adjustment_type: "Quantity").sum(:quantity_adjusted) + initial_quantity
    self.update_column(:available_quantity, quantity_to_update)
    value_to_update = quantity_to_update.to_f * buy_price.to_f
    value_to_update += self.stock_adjustments.where(adjustment_type: "Value").sum(:value_adjusted)
    self.update_column(:available_value, value_to_update)
  end

  def self.import(file)
    CSVManager.new(self, 'name', mapping).import(file)
  end

  def self.export
    CSVManager.new(self, 'name', mapping).export(self.find_each)
  end

  def self.mapping
    map = {}
    Klass.find_by(name: self.name).fields.each do |field|
      map[field.name] = field.label
    end
    map
  end

  def tax
    sprintf '%.2f', super.to_f
  end

  def create_attachments(company, current_user, attachments)
    documents.destroy_all
    return if attachments.blank?
    directory = company.directories.where(name: 'system').first
    attachments.each do |attachment|
      document = Document.create(resourcable: current_user, attachment: attachment)
      document.document_documentables.create(documentable: directory)
      document_documentables.create(document: document)
    end
  end

  def name_with_sku
    "#{name} (#{sku})"
  end

  def assigned_to_client?
    self.class.assigned_to_client?(self)
  end

  def self.assigned_to_client?(inventory)
    inventory.status == STATUSES[:assigned_to_client]
  end

  def valid_statuses
    STATUSES.values
  end

  def disabled_statuses
    [ STATUSES[:assigned_to_client] ]
  end

  def set_status_to_assigned_to_client
    self.update(status: STATUSES[:assigned_to_client])
  end

  def set_status_to_available
    self.update(status: STATUSES[:available])
  end

  # If status not set to `assigned to client` then, destroy inventory association if present
  # Note: We have to forcefully use `delete` instead of `destroy`
  #       because in case of `destroy` `Client::InventoryAssociation` updates inventory `status` by running callback and we loses the updated inventory `status`
  before_save do
    if !assigned_to_client?
      client_inventory_association&.delete
    end
  end

  # Set default status for new record
  after_initialize do
    if new_record?
      self.status ||= STATUSES[:available]
    end
  end
end
