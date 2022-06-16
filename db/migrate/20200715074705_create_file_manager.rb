class CreateFileManager < ActiveRecord::Migration[5.2]
  def change
    create_table :file_manager_folders do |t|
      t.string :name
      t.references :owner, polymorphic: true

      t.timestamps
    end

    create_table :file_manager_files do |t|
      t.string :attachment
      t.references :folder, { to_table: :file_manager_folders }
      t.references :owner, polymorphic: true

      t.timestamps
    end

    create_table :file_manager_file_associations do |t|
      t.string :title
      t.references :associable, polymorphic: true, index: { name: 'index_attachment_file_associations_on_associable' }
      t.references :field, foreign_key: true
      t.references :file, foreign_key: { to_table: :file_manager_files }

      t.timestamps
    end
  end
end
