class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :note
      t.string :type_task
      t.datetime :due_to
      t.datetime :email_reminder
      t.references :user, foreign_key: true
      t.string :taskable_type
      t.string :taskable_id

      t.timestamps
    end
    add_index :tasks, [:taskable_type,:taskable_id]
  end
end
