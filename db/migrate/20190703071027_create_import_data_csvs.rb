class CreateImportDataCsvs < ActiveRecord::Migration[5.1]
  def change
    create_table :import_data_csvs do |t|
      t.references :user, foreign_key: true
      t.references :document, foreign_key: true
      t.jsonb :data
      t.references :klass, foreign_key: true

      t.timestamps
    end
  end
end
