class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :status
      t.date :start_date
      t.date :end_date
      t.text :description

      t.timestamps
    end
  end
end
