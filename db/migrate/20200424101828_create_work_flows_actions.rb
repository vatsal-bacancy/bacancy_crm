class CreateWorkFlowsActions < ActiveRecord::Migration[5.1]
  def change
    create_table :work_flows_actions do |t|
      t.text :name
      t.text :to
      t.text :cc
      t.text :bcc
      t.text :subject
      t.text :description
      t.references :work_flow

      t.timestamps
    end
  end
end
