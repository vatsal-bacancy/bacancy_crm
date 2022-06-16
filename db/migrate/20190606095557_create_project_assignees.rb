class CreateProjectAssignees < ActiveRecord::Migration[5.1]
  def change
    create_table :project_assignees do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.string :email
      t.string :title
      t.string :company

      t.timestamps
    end
  end
end
