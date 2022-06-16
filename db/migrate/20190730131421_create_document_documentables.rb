class CreateDocumentDocumentables < ActiveRecord::Migration[5.1]
  def change
    create_table :document_documentables do |t|
      t.references :document, foreign_key: true
      t.references :documentable, polymorphic: true, index: { name: :document_documentable }

      t.timestamps

    end
  end
end
