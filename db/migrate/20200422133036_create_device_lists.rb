class CreateDeviceLists < ActiveRecord::Migration[5.1]
  def change
    create_table :device_lists do |t|
      t.string :product_name
      t.float :buy_price
      t.float :sell_price
      t.integer :user_id
      t.references :device
      t.references :product
      t.timestamps
    end
  end
end
