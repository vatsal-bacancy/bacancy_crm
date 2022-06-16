class AddAttachmentToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :attachment, :string
  end
end
