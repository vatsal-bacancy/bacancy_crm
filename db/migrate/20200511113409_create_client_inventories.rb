class CreateClientInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :client_inventories do |t|
      t.references :inventory_association
      t.references :inventory

      t.timestamps
    end
  end
end
