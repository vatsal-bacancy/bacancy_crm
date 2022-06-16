class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :product_name
      t.string :available
      t.string :unit_price
      t.string :purchase_cost
      t.string :qty_stock
      t.string :description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
