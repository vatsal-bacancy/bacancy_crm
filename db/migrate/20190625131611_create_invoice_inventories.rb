class CreateInvoiceInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_inventories do |t|
      t.float :qty, default: 0
      t.float :rate, default: 0
      t.float :tax, default: 0
      t.float :amount, default: 0
      t.string :description
      t.references :invoice, foreign_key: true
      t.references :inventory, foreign_key: true

      t.timestamps
    end
  end
end
