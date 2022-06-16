class AddTotalToWorkOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :work_orders, :hardware_total, :float
    add_column :work_orders, :plan_year, :string
    add_column :work_orders, :software_total, :float
    add_column :work_orders, :promotional_discount, :float
    add_column :work_orders, :final_amount, :float
    add_column :work_orders, :month_fee, :float
    add_column :work_orders, :up_front_hardware, :float
    add_column :work_orders, :up_front_software, :float
    add_column :work_orders, :up_front_promotional_discount, :float
    add_column :work_orders, :up_front_final_amount, :float
  end
end
