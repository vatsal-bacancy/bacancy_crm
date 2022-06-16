class AddGoogleEventIdInMeetings < ActiveRecord::Migration[5.1]
  def change
    add_column :meetings_meetings, :google_event_id, :string, default: ''
  end
end
