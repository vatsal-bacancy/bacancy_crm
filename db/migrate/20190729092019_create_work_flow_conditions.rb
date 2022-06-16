class CreateWorkFlowConditions < ActiveRecord::Migration[5.1]
  def change
    create_table :work_flow_conditions do |t|
      t.references :field, foreign_key: true
      t.string :comparison
      t.string :value
      t.references :work_flow, foreign_key: true
      t.string :condition_type
      t.timestamps
    end
  end
end
