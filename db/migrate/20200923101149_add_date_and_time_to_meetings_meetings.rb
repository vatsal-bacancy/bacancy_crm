class AddDateAndTimeToMeetingsMeetings < ActiveRecord::Migration[5.2]
  def change
    remove_column :meetings_meetings, :start_time, :datetime
    remove_column :meetings_meetings, :end_time, :datetime
    add_column :meetings_meetings, :date, :date
    add_column :meetings_meetings, :start_time, :time
    add_column :meetings_meetings, :end_time, :time
  end
end
