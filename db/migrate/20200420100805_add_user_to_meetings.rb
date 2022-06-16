class AddUserToMeetings < ActiveRecord::Migration[5.1]
  def change
    add_reference :meetings_meetings, :user, foreign_key: true
  end
end
