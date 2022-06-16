class AddIsRefurbishToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :is_refurbish, :boolean, default: false
    add_column :devices, :is_refurbish, :boolean, default: false
  end
end
