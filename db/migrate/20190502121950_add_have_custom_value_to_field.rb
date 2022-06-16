class AddHaveCustomValueToField < ActiveRecord::Migration[5.1]
  def change
    add_column :fields, :have_custom_value, :boolean, default: false
  end
end
