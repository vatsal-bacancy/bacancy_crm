class CreateMeetingsMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :meetings_meetings do |t|
      t.string :title
      t.references :meetingable, polymorphic: true
      t.datetime :start_time
      t.bigint :duration
      t.string :description

      t.timestamps
    end
  end
end
