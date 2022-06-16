class AddColumnsToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :initial_value, :float, default: 0.0
    add_column :inventories, :is_purchasable, :boolean, default: true
    add_column :inventories, :is_saleable, :boolean, default: true
    add_column :inventories, :is_trackable, :boolean, default: true
  end
end
