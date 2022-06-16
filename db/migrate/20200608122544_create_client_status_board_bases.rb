class CreateClientStatusBoardBases < ActiveRecord::Migration[5.2]
  def change
    create_table :client_status_board_bases do |t|
      t.date :due_diligence_completed_at
      t.date :menu_completed_at
      t.date :deployment_completed_at
      t.date :website_completed_at
      t.date :quality_assurance_completed_at
      t.date :training_1_completed_at
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
