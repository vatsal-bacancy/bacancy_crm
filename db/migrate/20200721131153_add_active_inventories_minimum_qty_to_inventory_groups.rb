class AddActiveInventoriesMinimumQtyToInventoryGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :inventory_groups, :active_inventories_minimum_qty, :integer, default: 0
  end
end
