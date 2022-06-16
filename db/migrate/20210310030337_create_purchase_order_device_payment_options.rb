class CreatePurchaseOrderDevicePaymentOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_device_payment_options do |t|
      t.references :device, foreign_key: { to_table: :purchase_order_devices }
      t.references :payment_option, foreign_key: { to_table: :purchase_order_payment_options }, index: {:name => "payment_option_index"}
      t.timestamps
    end
  end
end
