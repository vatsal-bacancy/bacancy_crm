class CreateWorkFlowsWorkFlows < ActiveRecord::Migration[5.1]
  def change
    create_table :work_flows_work_flows do |t|
      t.string :name
      t.references :klass
      t.integer :on
      t.string :description

      t.timestamps
    end
  end
end
