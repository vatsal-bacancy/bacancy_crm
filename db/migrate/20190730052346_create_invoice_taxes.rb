class CreateInvoiceTaxes < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_taxes do |t|
      t.string :name
      t.float :tax_rate

      t.timestamps
    end
  end
end
