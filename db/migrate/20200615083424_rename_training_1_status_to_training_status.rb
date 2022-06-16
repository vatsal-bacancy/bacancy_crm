class RenameTraining1StatusToTrainingStatus < ActiveRecord::Migration[5.2]
  def change
    rename_column :client_status_board_bases, :training_1_completed_at, :training_completed_at
  end
end
