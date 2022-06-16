class DropWorkOrders < ActiveRecord::Migration[5.2]
  def change
    drop_table :work_orders
    drop_table :work_order_items
    drop_table :devices
    drop_table :device_lists
    drop_table :device_categories
    drop_table :products
  end
end
