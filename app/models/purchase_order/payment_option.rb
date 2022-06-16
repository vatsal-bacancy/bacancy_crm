class PurchaseOrder::PaymentOption < ApplicationRecord
  has_many :device_payment_options, class_name: 'PurchaseOrder::DevicePaymentOption', dependent: :destroy
  enum payment_type: [:F, :P, :E, :S]
end
