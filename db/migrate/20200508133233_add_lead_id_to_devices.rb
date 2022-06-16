class AddLeadIdToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :work_orders, :lead_id, :integer
    add_column :work_orders, :is_refurbish, :boolean, default: false
  end
end
