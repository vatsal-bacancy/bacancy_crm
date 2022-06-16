class ChangeQtyTypeInInvoiceInventories < ActiveRecord::Migration[5.1]
  def up
    change_column :invoice_inventories, :qty, :integer
  end

  def down
    change_column :invoice_inventories, :qty, :float
  end
end
