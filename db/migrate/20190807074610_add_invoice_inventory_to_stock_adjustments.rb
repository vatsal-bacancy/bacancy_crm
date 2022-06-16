class AddInvoiceInventoryToStockAdjustments < ActiveRecord::Migration[5.1]
  def change
    add_reference :stock_adjustments, :invoice_inventory, foreign_key: true
  end
end
