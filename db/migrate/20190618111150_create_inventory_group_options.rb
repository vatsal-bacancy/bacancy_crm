class CreateInventoryGroupOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :inventory_group_options do |t|
      t.references :attribute_option, foreign_key: true
      t.references :inventory_group, foreign_key: true
      t.string :options,array: true, default: []

      t.timestamps
    end
  end
end
