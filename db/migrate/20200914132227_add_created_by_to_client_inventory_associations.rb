class AddCreatedByToClientInventoryAssociations < ActiveRecord::Migration[5.2]
  def change
      add_reference :client_inventory_associations, :created_by, foreign_key: { to_table: :users }
  end
end
