class ChangeColumnFromStockAdjustments < ActiveRecord::Migration[5.1]
  def change
    change_column :stock_adjustments, :quantity_adjusted, :float
    change_column :stock_adjustments, :new_quantity_on_hand, :float
    change_column :inventories, :initial_quantity, :float
    change_column :inventories, :available_quantity, :float
  end
end
