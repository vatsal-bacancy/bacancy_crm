class AddVendorToInventories < ActiveRecord::Migration[5.2]
  def change
    add_reference :inventories, :vendor, foreign_key: true
    add_column :inventories, :purchase_date, :datetime
    add_column :inventories, :purchase_order_number, :string
  end
end
