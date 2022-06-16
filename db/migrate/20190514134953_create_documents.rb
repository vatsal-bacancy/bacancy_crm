class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string :attachment
      # t.references :documentable, polymorphic: true
      # t.references :user, foreign_key: true
      t.references :resourcable, polymorphic: true
      t.references :directory, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
