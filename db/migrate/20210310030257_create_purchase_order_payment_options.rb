class CreatePurchaseOrderPaymentOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_payment_options do |t|
      t.integer :payment_type
      t.timestamps
    end
  end
end
