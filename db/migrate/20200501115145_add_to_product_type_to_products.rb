class AddToProductTypeToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :pro_type, :string
    add_column :device_lists, :software, :float
    add_column :device_lists, :hardware, :float
  end
end
