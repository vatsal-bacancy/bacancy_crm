class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.string :content
      t.references :commentable, polymorphic: true, index: true
      t.references :user, foreign_key: true
      t.string :attachment
      t.timestamps
    end
  end
end
