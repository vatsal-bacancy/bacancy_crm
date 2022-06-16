class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.string :content
      t.string :noteable_type
      t.string :noteable_id
      t.references :user

      t.timestamps
    end
    add_index :notes, [:noteable_id,:noteable_type]
  end
end
