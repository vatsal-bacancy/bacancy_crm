class CreateDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices do |t|
    	t.string :name
      t.references :category, foreign_key: true
      t.references :subcategory, foreign_key: true
      t.references :user, foreign_key: true
      t.string :description
      t.boolean :none_inevntory, default: false
      t.timestamps
    end
  end
end
