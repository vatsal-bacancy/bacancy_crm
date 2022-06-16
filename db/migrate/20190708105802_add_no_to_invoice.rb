class AddNoToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :invoice_no, :string
  end
end
