class AddDueFromAgentInWorkOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :work_orders, :due_from_agent, :float, default: 0.0
    add_column :work_orders, :up_front_due_from_agent, :float, default: 0.0
  end
end
