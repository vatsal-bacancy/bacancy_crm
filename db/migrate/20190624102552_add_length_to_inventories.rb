class AddLengthToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :length, :integer
    add_column :inventories, :height, :integer
    add_column :inventories, :width, :integer
  end
end
