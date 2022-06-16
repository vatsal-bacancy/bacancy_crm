class AddInventoryToClientInventoryAssociations < ActiveRecord::Migration[5.1]
  def change
    add_reference :client_inventory_associations, :inventory, foreign_key: true
  end
end
