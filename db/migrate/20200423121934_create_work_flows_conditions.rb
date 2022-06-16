class CreateWorkFlowsConditions < ActiveRecord::Migration[5.1]
  def change
    create_table :work_flows_or_conditions do |t|
      t.integer :comparator
      t.string :value
      t.references :field, foreign_key: true
      t.references :work_flow

      t.timestamps
    end
    create_table :work_flows_and_conditions do |t|
      t.integer :comparator
      t.string :value
      t.references :field, foreign_key: true
      t.references :work_flow

      t.timestamps
    end
  end
end
