class PurchaseOrder::DevicePaymentOption < ApplicationRecord
  belongs_to :device, class_name: 'PurchaseOrder::Device'
  belongs_to :payment_option, class_name: 'PurchaseOrder::PaymentOption'
end
