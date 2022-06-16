class AddColumnToPurchaseOrderVersion < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_versions, :upfront_due_from_client, :float, default: 0
    add_column :purchase_order_versions, :upfront_promotional_discount_code, :string
  end
end
