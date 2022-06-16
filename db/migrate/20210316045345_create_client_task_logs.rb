class CreateClientTaskLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :client_task_logs do |t|
      t.references :user, foreign_key: true
      t.references :client, foreign_key: true
      t.string :location_latitude, default: ''
      t.string :location_longitude, default: ''
      t.string :app_checkin, default: ''
      t.string :app_checkout, default: ''
      t.timestamps
    end
  end
end
