class CreateAssociates < ActiveRecord::Migration[5.1]
  def change
    create_table :associates do |t|
      t.string :associateable_id
      t.string :associateable_type

      t.timestamps
    end
    add_index :associates, [:associateable_id, :associateable_type]
  end
end
