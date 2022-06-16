class CreateFieldPicklistValues < ActiveRecord::Migration[5.1]
  def change
    create_table :field_picklist_values do |t|
      t.references :field, foreign_key: true
      t.string :value
      t.integer :position

      t.timestamps
    end
  end
end
