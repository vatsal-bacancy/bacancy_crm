class AddColorToFieldPicklistValues < ActiveRecord::Migration[5.2]
  def change
    add_column :field_picklist_values, :color, :string
  end
end
