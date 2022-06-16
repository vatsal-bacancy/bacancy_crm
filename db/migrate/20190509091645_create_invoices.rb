class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.references :client
      t.string :invoice_number
      t.string :billing_address
      t.string :terms
      t.string :email
      t.integer :order_number
      t.date :invoice_date
      t.date :due_date
      t.string :msg_on_invoice
      t.string :msg_on_statement
      t.references :sales_person, index: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
