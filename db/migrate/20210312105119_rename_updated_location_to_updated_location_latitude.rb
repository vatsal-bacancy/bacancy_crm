class RenameUpdatedLocationToUpdatedLocationLatitude < ActiveRecord::Migration[5.2]
  def change
    rename_column :fields, :updated_location, :updated_location_latitude
  end
end
