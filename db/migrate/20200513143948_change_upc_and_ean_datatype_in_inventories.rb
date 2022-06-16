class ChangeUpcAndEanDatatypeInInventories < ActiveRecord::Migration[5.1]
  def change
    change_column :inventories, :upc, :string
    change_column :inventories, :ean, :string
  end
end
