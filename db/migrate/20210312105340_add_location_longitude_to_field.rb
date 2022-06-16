class AddLocationLongitudeToField < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :updated_location_longitude, :string, default: ''
  end
end
