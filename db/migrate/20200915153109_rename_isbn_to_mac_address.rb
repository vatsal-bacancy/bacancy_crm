class RenameIsbnToMacAddress < ActiveRecord::Migration[5.2]
  def change
    rename_column :inventories, :isbn, :mac_address
  end
end
