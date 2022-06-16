class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :label
      t.references :klass, foreign_key: true
      t.integer :position
      t.string :hint

      t.timestamps
    end
  end
end
