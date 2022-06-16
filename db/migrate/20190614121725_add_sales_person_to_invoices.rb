class AddSalesPersonToInvoices < ActiveRecord::Migration[5.1]
  def change
    unless Invoice.column_names.include?("sales_person_id")
      add_column :invoices, :sales_person_id, :integer
    end
  end
end
