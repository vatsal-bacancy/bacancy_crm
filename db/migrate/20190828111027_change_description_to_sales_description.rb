class ChangeDescriptionToSalesDescription < ActiveRecord::Migration[5.1]
  def change
    rename_column :inventories, :description, :sales_description
    add_column :inventories, :purchase_description, :string
  end
end
