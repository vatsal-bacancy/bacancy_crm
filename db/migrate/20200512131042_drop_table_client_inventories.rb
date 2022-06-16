class DropTableClientInventories < ActiveRecord::Migration[5.1]
  def change
    drop_table :client_inventories
    # clearing the records of inventory_association and mark all inventory as active
    Client::InventoryAssociation.destroy_all
    Inventory.update_all(active: true)
  end
end
