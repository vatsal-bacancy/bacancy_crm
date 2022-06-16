class Api::V1::UserTaskLogsController < Api::V1::BaseController
  skip_before_action :verify_authenticity_token

  def checkin
    if user.present?
      user_client_tasks_log = ClientTaskLog.find_or_create_by(user_id: user.id, client_id: params[:client_id])
      user_client_tasks_log.user_checkin_timestamp = params[:user_checkin_timestamp]
      user_client_tasks_log.checkin_latitude = params[:checkin_latitude]
      user_client_tasks_log.checkin_longitude = params[:checkin_longitude]
      if user_client_tasks_log.save
        checkin_timestamp = params[:user_checkin_timestamp]&.to_datetime
        if client.present?
          client.status_board.update(pre_installation_start_date: checkin_timestamp, pre_training_start_date: checkin_timestamp, employee_training_start_date: checkin_timestamp, owner_manager_ipos_back_office_training_start_date: checkin_timestamp,
            pre_installation_end_date: nil, pre_training_end_date: nil, employee_training_end_date: nil, owner_manager_ipos_back_office_training_end_date: nil)
          client.update(pre_installation_status: 'In Progress', pre_training_status: 'In Progress', employee_training_status: 'In Progress', owner_manager_ipos_back_office_training_status: 'In Progress')
        end
        task_log_hash = client_task_log_details(user_client_tasks_log)
        api_success(200, 'Successfully Checked In.', task_log_hash)
      else
        api_error(400, 'Not checked in!')
      end
    else
      api_error(400, 'User not found!')
    end
  end

  def checkout
    if user.present?
      user_client_tasks_log = ClientTaskLog.find_or_create_by(user_id: user.id, client_id: params[:client_id])
      user_client_tasks_log.user_checkout_timestamp = params[:user_checkout_timestamp]
      user_client_tasks_log.checkout_latitude = params[:checkout_latitude]
      user_client_tasks_log.checkout_longitude = params[:checkout_longitude]
      if user_client_tasks_log.save
        checkout_timestamp = params[:user_checkout_timestamp]&.to_datetime
        if client.present?
          # pre_installation_end_date: checkout_timestamp, pre_training_end_date: checkout_timestamp, employee_training_end_date: checkout_timestamp, owner_manager_ipos_back_office_training_end_date: checkout_timestamp
          client.status_board.update(qa_by_pos_management_start_date: checkout_timestamp)
          client.update(pre_installation_status: 'Completed', pre_training_status: 'Completed', employee_training_status: 'Completed', owner_manager_ipos_back_office_training_status: 'Completed', qa_by_pos_management_status: 'In Progress')
        end
        task_log_hash = client_task_log_details(user_client_tasks_log)
        api_success(200, 'Successfully Checked Out.', task_log_hash)
      else
        api_error(400, 'Not checked out!')
      end
    else
      api_error(400, 'User not found!')
    end
  end

  private

  def client
    @client ||= Client.find_by_id(params[:client_id])
  end

  def user
    user_phone_number = ''
    if params['country_code'].to_i != 1
      user_phone_number = params['country_code'].gsub(' ', '+') + params['phone_number']
    else
      user_phone_number = params['phone_number']
    end
    @user ||= User.find_by_phone_no(user_phone_number)
  end

  def client_task_log_details(user_client_tasks_log)
    ClientTaskLog.where(id: user_client_tasks_log.id).select(:id, :user_id, :client_id, :checkin_latitude, :checkin_longitude, :checkout_latitude, :checkout_longitude, :user_checkin_timestamp, :user_checkout_timestamp).as_json.first
  end
end
