class RemoveOrderNumberFromInvoices < ActiveRecord::Migration[5.1]
  def change
    remove_column :invoices, :order_number, :string
  end
end
