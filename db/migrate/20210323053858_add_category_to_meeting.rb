class AddCategoryToMeeting < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings_meetings, :category, :integer
  end
end
