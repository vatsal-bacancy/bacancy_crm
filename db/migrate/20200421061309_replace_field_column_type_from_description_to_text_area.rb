class ReplaceFieldColumnTypeFromDescriptionToTextArea < ActiveRecord::Migration[5.1]
  def up
    Field.where(column_type: 'Description').update_all(column_type: 'Text Area')
  end
  def down
    Field.where(column_type: 'Text Area').update_all(column_type: 'Description')
  end
end
