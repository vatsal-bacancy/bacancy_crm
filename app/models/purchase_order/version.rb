class PurchaseOrder::Version < ApplicationRecord
  default_scope { order(created_at: :desc) }

  belongs_to :purchase_orderable, polymorphic: true
  belongs_to :created_by, class_name: 'User'

  after_initialize :set_defaults

  def devices=(attributes)
    attributes.delete_if{ |k, v| v[:quantity].blank? }
    device_ids = attributes.keys
    serialized = PurchaseOrder::Device.includes(:products).where(id: device_ids).map do |device|
      meta_data = attributes[device.id.to_s]
      device.as_json.merge(products_price: meta_data[:products_price].to_f,
                           quantity: meta_data[:quantity].to_i,
                           total: meta_data[:total].to_f,
                           products: device.products,
                           payment_options: device.payment_options.pluck(:payment_type).join(' '))
    end
    self.serialized_devices = serialized.to_json(except: 'id')
  end

  def devices
    @devices ||= JSON.parse self.serialized_devices, object_class: OpenStruct
  end

  def devices_with_category
    devices.group_by{ |device| device.category }
  end

  private

  def set_defaults
    return unless new_record?
    self.serialized_devices ||= '[]'
    self.financed_payment_year_plan ||= 2
  end
end
