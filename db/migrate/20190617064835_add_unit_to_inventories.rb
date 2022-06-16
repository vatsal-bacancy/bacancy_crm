class AddUnitToInventories < ActiveRecord::Migration[5.1]
  def change
    add_reference :inventories, :unit, foreign_key: true
    add_reference :inventory_groups, :unit, foreign_key: true

    add_column :inventories, :returnable, :boolean, default: false
    add_column :inventory_groups, :returnable, :boolean, default: false

    add_column :inventories, :is_service, :boolean, default: false
    add_column :inventory_groups, :is_service, :boolean, default: false

    add_column :inventories, :reorder_level, :integer, default: false    

    add_column :inventories, :upc, :integer, default: false    
    add_column :inventories, :ean, :integer, default: false    
    add_column :inventories, :isbn, :integer, default: false    
  end
end
