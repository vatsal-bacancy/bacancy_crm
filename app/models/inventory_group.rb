class InventoryGroup < ApplicationRecord
  default_scope -> { order(:name) }

  belongs_to :category, optional: true
  belongs_to :subcategory, optional: true
  belongs_to :user
  belongs_to :brand, optional: true
  belongs_to :merchant, optional: true
  belongs_to :unit, optional: true

  has_many :inventory_group_options, dependent: :destroy
  has_many :inventories, dependent: :destroy

  mount_uploader :image, AttachmentUploader

  PERMITTED_PARAMS = [:is_service, :brand_id, :merchant_id, :name, :description, :category_id, :subcategory_id, :user_id, :is_taxable, :unit_id, :returnable, :multiple_inventories, :image, :active_inventories_minimum_qty, inventory_group_options_attributes: InventoryGroupOption::PERMITTED_PARAMS, inventories_attributes: Inventory::PERMITTED_PARAMS]
  COMMON_INVENTORY_PARAMS = %i[is_service  returnable  is_taxable  unit_id  category_id  merchant_id  brand_id subcategory_id]
  validates_presence_of :name, :user

  accepts_nested_attributes_for :inventory_group_options, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :inventories, reject_if: :all_blank, allow_destroy: true

  def active_inventories
    @active_inventories ||= inventories.active
  end

  def under_stock?
    active_inventories.size < active_inventories_minimum_qty
  end

  def image_path_for_image_tag
    image.url.present? ? image.url : 'inv-placeholder.png' 
  end

  def reference_export
    name
  end

  def self.reference_import(name)
    self.find_by!(name: name)
  end
end
