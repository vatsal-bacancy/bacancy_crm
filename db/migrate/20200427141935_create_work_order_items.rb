class CreateWorkOrderItems < ActiveRecord::Migration[5.1]
  def change
    create_table :work_order_items do |t|
      t.integer :product_id
      t.float :price
      t.integer :quantity
      t.float :total
      t.string :product_ids, array: true, default: []
      t.integer :work_order_id
      t.timestamps
    end
  end
end
