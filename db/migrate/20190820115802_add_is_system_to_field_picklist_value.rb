class AddIsSystemToFieldPicklistValue < ActiveRecord::Migration[5.1]
  def change
    add_column :field_picklist_values, :is_system, :boolean, default: false
  end
end
