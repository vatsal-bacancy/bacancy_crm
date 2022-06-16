class CreateWorkOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :work_orders do |t|
      t.string :device_name
      t.integer :device_id
      t.integer :category_id
      t.integer :client_id
      t.timestamps
    end
  end
end
