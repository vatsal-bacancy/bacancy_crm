class ChangeDefaultQuantity < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:inventories, :available_quantity, 0)
  end
end
