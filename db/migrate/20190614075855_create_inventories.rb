class CreateInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :inventories do |t|
      t.references :inventory_group, foreign_key: true
      t.references :user, foreign_key: true
      t.float :buy_price
      t.float :sell_price
      t.string :image
      t.string :barcode
      t.boolean :is_taxable
      t.string :sku
      t.integer :available_quantity

      t.timestamps
    end
  end
end
