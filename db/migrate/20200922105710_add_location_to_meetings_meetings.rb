class AddLocationToMeetingsMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings_meetings, :location, :string
  end
end
