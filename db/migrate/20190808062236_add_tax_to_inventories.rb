class AddTaxToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :tax, :float, default: 0.0
    change_column :inventories, :is_taxable, :boolean, default: false
  end
end
