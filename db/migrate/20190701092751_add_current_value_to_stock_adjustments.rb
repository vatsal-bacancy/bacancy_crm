class AddCurrentValueToStockAdjustments < ActiveRecord::Migration[5.1]
  def change
    add_column :stock_adjustments, :current_value, :float
    add_column :stock_adjustments, :current_quantity, :integer
    add_column :inventories, :available_value, :float, default: 0.0
    change_column_default(:inventories, :available_quantity, 0.0)
  end
end
