class RemoveHeaderViewAndHeadPositionFromField < ActiveRecord::Migration[5.2]
  def change
    remove_column :fields, :head_position, :integer
    remove_column :fields, :header_view, :boolean
  end
end
