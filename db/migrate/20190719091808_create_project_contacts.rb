class CreateProjectContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :project_contacts do |t|
      t.references :project, foreign_key: true
      t.references :contact, foreign_key: true
      t.references :client, foreign_key: true
      t.boolean :status

      t.timestamps
    end
  end
end
