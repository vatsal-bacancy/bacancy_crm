class CreateModuleNumbers < ActiveRecord::Migration[5.1]
  def change
    create_table :module_numbers do |t|
      t.references :klass, foreign_key: true
      t.string :module_prefix
      t.string :sequence_start

      t.timestamps
    end
  end
end
