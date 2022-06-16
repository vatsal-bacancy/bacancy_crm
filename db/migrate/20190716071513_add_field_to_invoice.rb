class AddFieldToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :cc, :string
    add_column :invoices, :bcc, :string
  end
end
