class CreateCustomValues < ActiveRecord::Migration[5.1]
  def change
    create_table :custom_values do |t|
      t.references :field, foreign_key: true
      t.string :value
      t.references :valuable, polymorphic: true

      t.timestamps
    end
  end
end
