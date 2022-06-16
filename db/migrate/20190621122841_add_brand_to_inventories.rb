class AddBrandToInventories < ActiveRecord::Migration[5.1]
  def change
    add_reference :inventories, :brand, foreign_key: true
    add_reference :inventories, :merchant, foreign_key: true
    add_reference :inventories, :category, foreign_key: true
    add_reference :inventories, :subcategory, foreign_key: true
  end
end
