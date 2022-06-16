class ChangeDurationToBeDatetimeInMeetings < ActiveRecord::Migration[5.1]
  def change
    remove_column :meetings_meetings, :duration
    add_column :meetings_meetings, :end_time, :datetime
  end
end
