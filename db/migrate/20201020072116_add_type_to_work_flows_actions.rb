class AddTypeToWorkFlowsActions < ActiveRecord::Migration[5.2]
  def change
    add_column :work_flows_actions, :type, :string
  end
end
