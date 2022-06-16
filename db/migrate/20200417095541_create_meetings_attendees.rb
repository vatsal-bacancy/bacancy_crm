class CreateMeetingsAttendees < ActiveRecord::Migration[5.1]
  def change
    create_table :meetings_attendees do |t|
      t.references :meeting
      t.references :resourceable, polymorphic: true, index: false

      t.timestamps
    end
  end
end
