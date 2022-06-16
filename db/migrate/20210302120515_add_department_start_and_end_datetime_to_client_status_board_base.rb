class AddDepartmentStartAndEndDatetimeToClientStatusBoardBase < ActiveRecord::Migration[5.2]
  def change
    add_column :client_status_board_bases, :qr_code_order_taking_start_date, :datetime
    add_column :client_status_board_bases, :qr_code_order_taking_end_date, :datetime

    add_column :client_status_board_bases, :eats_business_website_setup_start_date, :datetime
    add_column :client_status_board_bases, :eats_business_website_setup_end_date, :datetime

    add_column :client_status_board_bases, :ipos_eats_app_setup_start_date, :datetime
    add_column :client_status_board_bases, :ipos_eats_app_setup_end_date, :datetime

    add_column :client_status_board_bases, :hq_po_start_date, :datetime
    add_column :client_status_board_bases, :hq_po_end_date, :datetime

    add_column :client_status_board_bases, :pre_installation_start_date, :datetime
    add_column :client_status_board_bases, :pre_installation_end_date, :datetime

    add_column :client_status_board_bases, :pre_training_start_date, :datetime
    add_column :client_status_board_bases, :pre_training_end_date, :datetime

    add_column :client_status_board_bases, :employee_training_start_date, :datetime
    add_column :client_status_board_bases, :employee_training_end_date, :datetime

    add_column :client_status_board_bases, :owner_manager_ipos_back_office_training_start_date, :datetime
    add_column :client_status_board_bases, :owner_manager_ipos_back_office_training_end_date, :datetime

    add_column :client_status_board_bases, :qa_by_pos_management_start_date, :datetime
    add_column :client_status_board_bases, :qa_by_pos_management_end_date, :datetime
  end
end
