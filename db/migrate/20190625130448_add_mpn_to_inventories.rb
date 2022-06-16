class AddMpnToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :mpn, :string
    add_column :inventories, :description, :string
    remove_column :inventories, :isbn
    add_column :inventories, :isbn, :string, default: false    
  end
end
