class PurchaseOrder::Device < ApplicationRecord
  has_many :device_products, class_name: 'PurchaseOrder::DeviceProduct', dependent: :destroy
  has_many :products, through: :device_products
  has_many :device_payment_options, class_name: 'PurchaseOrder::DevicePaymentOption', dependent: :destroy
  has_many :payment_options, through: :device_payment_options

  accepts_nested_attributes_for :device_products, allow_destroy: true

  def hardware_products_price
    @hardware_products_price ||= products.select{|product| product.hardware?}.sum(&:price)
  end

  def software_products_price
    @software_products_price ||= products.select{|product| product.software?}.sum(&:price)
  end

  def products_price
    hardware_products_price + software_products_price
  end

  def self.all_categories
    all.pluck(:category).uniq
  end

  def self.sort_by_order_with_category
    all.order(:order).group_by{ |device| device.category }
  end
end
