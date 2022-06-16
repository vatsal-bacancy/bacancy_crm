class AddResourcableToDocumentDocumentable < ActiveRecord::Migration[5.1]
  def change
    add_reference :document_documentables, :resourcable, polymorphic: true, index: { name: 'documentables_resourcable_index'}
    #add_index :document_documentables,["resourcable_type", "resourcable_id"], :name => 'documentables_resourcable_index'
  end

end
