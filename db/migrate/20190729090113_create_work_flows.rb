class CreateWorkFlows < ActiveRecord::Migration[5.1]
  def change
    create_table :work_flows do |t|
      t.string :name
      t.text :description
      t.references :klass, foreign_key: true
      t.boolean :status
      t.string :callback
      t.boolean :reccuring

      t.timestamps
    end
  end
end
