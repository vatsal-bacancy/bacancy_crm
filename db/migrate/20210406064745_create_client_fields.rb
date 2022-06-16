class CreateClientFields < ActiveRecord::Migration[5.2]
  def change
    create_table :client_fields do |t|
      t.references :client, foreign_key: true
      t.references :field, foreign_key: true
      t.string :updated_location_latitude, default: ''
      t.string :updated_location_longitude, default: ''
      t.string :updated_timestamp, default: ''
      t.timestamps
    end
  end
end
