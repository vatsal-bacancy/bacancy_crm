class AddInitialQuantityToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :initial_quantity, :integer, default: 0
  end
end
