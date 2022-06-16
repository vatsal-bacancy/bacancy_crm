class CreateDirectories < ActiveRecord::Migration[5.1]
  def change
    create_table :directories do |t|
      t.string :name
      t.references :directoriable, polymorphic: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
