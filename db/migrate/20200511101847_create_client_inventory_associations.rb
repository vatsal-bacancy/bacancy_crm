class CreateClientInventoryAssociations < ActiveRecord::Migration[5.1]
  def up
    StockAdjustmentReason.find_or_create_by(reason: 'Client inventory association')
    create_table :client_inventory_associations do |t|
      t.references :client

      t.timestamps
    end
  end
  def down
    drop_table :client_inventory_associations
    StockAdjustmentReason.find_by(reason: 'Client inventory association').destroy
  end
end
