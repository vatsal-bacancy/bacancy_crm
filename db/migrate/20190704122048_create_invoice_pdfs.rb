class CreateInvoicePdfs < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_pdfs do |t|
      t.references :invoice

      t.timestamps
    end
  end
end
