class CreateProjectManagement < ActiveRecord::Migration[5.2]
  def change
    create_table :project_management_projects do |t|
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :client, foreign_key: true
      t.string :name
      t.string :status
      t.date :start_date
      t.date :end_date
      t.text :description

      t.timestamps
    end

    create_table :project_management_project_tasks do |t|
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.references :project, foreign_key: { to_table: :project_management_projects }
      t.string :title
      t.string :priority
      t.string :status
      t.date :start_date
      t.date :due_date
      t.text :description

      t.timestamps
    end

    create_table :project_management_project_task_comments do |t|
      t.references :task, foreign_key: { to_table: :project_management_project_tasks }
      t.references :created_by, foreign_key: { to_table: :users }
      t.text :description

      t.timestamps
    end

    create_table :project_management_project_resources do |t|
      t.references :resourceable, polymorphic: true, index: { name: 'index_project_management_resourceable' }
      t.references :project, foreign_key: { to_table: :project_management_projects }

      t.timestamps
    end
  end
end
