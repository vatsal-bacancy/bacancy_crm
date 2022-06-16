class DropWorkFlows < ActiveRecord::Migration[5.1]
  def change
    drop_table :work_flow_conditions
    drop_table :work_flows
  end
end
