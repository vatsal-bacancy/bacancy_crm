class ReplaceDynamicColumnTypeTextAreaWithTextAreaHtml < ActiveRecord::Migration[5.1]
  def up
    Field.where(column_type: 'Text-Area').update_all(column_type: 'Text Area HTML')
  end
  def down
    Field.where(column_type: 'Text Area HTML').update_all(column_type: 'Text-Area')
  end
end
