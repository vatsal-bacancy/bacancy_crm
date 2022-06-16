class AddTaxToInvoiceInventory < ActiveRecord::Migration[5.1]
  def change
    #add_reference :invoice_inventories, :invoice_taxes, foreign_key: true
  end
end
