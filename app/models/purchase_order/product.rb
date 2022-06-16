class PurchaseOrder::Product < ApplicationRecord
  has_many :device_products, class_name: 'PurchaseOrder::DeviceProduct', dependent: :destroy

  enum product_type: [:hardware, :software]

  after_initialize :set_defaults

  private

  def set_defaults
    return unless new_record?
    self.product_type ||= :hardware
    self.available ||= true
  end
end
