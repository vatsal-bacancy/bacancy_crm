class AddMultipleInventoriesToInventoryGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :inventory_groups, :multiple_inventories, :boolean, default: false
    add_column :inventory_groups, :is_taxable, :boolean, default: true
  end
end
