class ChangeColumnsFromInventories < ActiveRecord::Migration[5.1]
  def change
    change_column :inventories, :initial_quantity, :integer
    change_column :inventories, :available_quantity, :integer
  end
end
