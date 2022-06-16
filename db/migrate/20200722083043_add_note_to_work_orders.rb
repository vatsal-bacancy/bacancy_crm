class AddNoteToWorkOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :work_orders, :note, :string
  end
end
