class RemoveUnusedColumnsFromWorkOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :work_orders, :category_id, :integer
    remove_reference :devices, :subcategory
  end
end
