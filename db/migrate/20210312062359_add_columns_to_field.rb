class AddColumnsToField < ActiveRecord::Migration[5.2]
  def change
    # As per mobile side API requirements
    add_column :fields, :updated_location, :string, default: ''
    add_column :fields, :updated_timestamp, :string, default: ''
  end
end
