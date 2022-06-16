class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.string :title
      t.string :category
      t.string :priority
      t.string :status
      t.string :description
      t.references :messageable, polymorphic: true
      # t.references :user, foreign_key: e
      t.references :resourcable, polymorphic: true
      t.timestamps
    end
  end
end
