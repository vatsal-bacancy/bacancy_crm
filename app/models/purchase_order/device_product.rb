class PurchaseOrder::DeviceProduct < ApplicationRecord
  belongs_to :device, class_name: 'PurchaseOrder::Device'
  belongs_to :product, class_name: 'PurchaseOrder::Product'
end
