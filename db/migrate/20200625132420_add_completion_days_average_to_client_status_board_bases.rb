class AddCompletionDaysAverageToClientStatusBoardBases < ActiveRecord::Migration[5.2]
  def change
    add_column :client_status_board_bases, :completion_days_average, :float

    Client::StatusBoard::Base.all.each do |status_board|
      status_board.calculate_completion_days_average
      status_board.save
    end
  end
end
