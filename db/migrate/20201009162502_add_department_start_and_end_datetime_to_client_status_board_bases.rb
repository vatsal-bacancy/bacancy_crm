class AddDepartmentStartAndEndDatetimeToClientStatusBoardBases < ActiveRecord::Migration[5.2]
  def change
    add_column :client_status_board_bases, :boarding_qa_start_date, :datetime
    add_column :client_status_board_bases, :boarding_qa_end_date, :datetime
    add_column :client_status_board_bases, :due_diligence_start_date, :datetime
    add_column :client_status_board_bases, :due_diligence_end_date, :datetime
    add_column :client_status_board_bases, :menu_india_start_date, :datetime
    add_column :client_status_board_bases, :menu_india_end_date, :datetime
    add_column :client_status_board_bases, :menu_usa_start_date, :datetime
    add_column :client_status_board_bases, :menu_usa_end_date, :datetime
    add_column :client_status_board_bases, :olo_start_date, :datetime
    add_column :client_status_board_bases, :olo_end_date, :datetime
    add_column :client_status_board_bases, :deployment_start_date, :datetime
    add_column :client_status_board_bases, :deployment_end_date, :datetime
    add_column :client_status_board_bases, :inventory_allocation_start_date, :datetime
    add_column :client_status_board_bases, :inventory_allocation_end_date, :datetime
    remove_column :client_status_board_bases, :due_diligence_completed_at, :date
    remove_column :client_status_board_bases, :menu_completed_at, :date
    remove_column :client_status_board_bases, :deployment_completed_at, :date
    remove_column :client_status_board_bases, :website_completed_at, :date
    remove_column :client_status_board_bases, :quality_assurance_completed_at, :date
    remove_column :client_status_board_bases, :training_completed_at, :date
    remove_column :client_status_board_bases, :completion_days_average, :float
  end
end
