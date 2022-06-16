class AddBrandToInventoryGroups < ActiveRecord::Migration[5.1]
  def change
    add_reference :inventory_groups, :brand, foreign_key: true
    add_reference :inventory_groups, :merchant, foreign_key: true
  end
end
