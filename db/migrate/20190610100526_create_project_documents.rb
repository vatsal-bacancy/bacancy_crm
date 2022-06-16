class CreateProjectDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :project_documents do |t|
      t.string :attachment
      t.references :project, foreign_key: true
      # t.references :user, foreign_key: true
      t.references :resourcable, polymorphic: true

      t.timestamps
    end
  end
end
