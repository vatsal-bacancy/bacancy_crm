class Api::V1::TasksController < Api::V1::BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :select_company
  skip_before_action :set_action

  # Here, We've considered `User` as a Chat User (Project: `Support Chat`).
  #                        `Group` as a Main Task.
  #                        `Field` as a Sub Task.
  # TODO: Setup Authentication from `Support Chat`.

  def index
    klass = Klass.find_by(name: 'Client')
    user = find_user(params['country_code'], params['phone_number'])
    main_hash = {}
    main_array = []
    if user.present?
      # If client_id present, take only that client. Otherwise User's all clients with `Production Mode`
      clients = params['client_id'].present? ? user.clients.assigned_client(params['client_id']) : user.clients.assigned_clients

      # To update data for `status_board`
      ApiTaskWorker.perform_async('index_task', { user_fullname: user.fullname, client_ids: clients.ids })

      task_group = user.clients_groups(klass)
      main_array = Client.build_client_array(task_group, clients, user)
    end
    main_hash['client'] = main_array
    api_success(200, 'All Tasks successfully fetched.', main_hash)
  end

  # TODO: Need to improve
  def update_task
    user = find_user(params['data']['country_code'], params['data']['phone_number'])
    client = Client.find_by_id task_params[:client_id]
    group = Group.find_by_id task_params[:task_id]
    sub_task = []
    if user.present?
      if client.present? && (user.clients.include? client)
        task_params[:sub_task].each do |task|
          field = Field.find_by_id task[:id]
          next unless field.present?

          value = task[:value]
          client.update_column(field.name.to_sym, value)
          # field.update_columns(updated_location_latitude: task[:updated_location_latitude], updated_location_longitude: task[:updated_location_longitude], updated_timestamp: task[:updated_timestamp])
          cf = ClientField.find_or_create_by(client_id: client.id, field_id: field.id)
          location_address = geo_location(task[:updated_location_latitude], task[:updated_location_longitude])
          cf.update_columns(updated_location_latitude: task[:updated_location_latitude],
                            updated_location_longitude: task[:updated_location_longitude],
                            updated_timestamp: task[:updated_timestamp], updated_address: location_address)
          task_object = { id: field.id, name: field.name, label: field.label, column_type: field.column_type,
                          group_id: field.group_id, updated_location_latitude: cf.updated_location_latitude,
                          updated_location_longitude: cf.updated_location_longitude,
                          updated_timestamp: cf.updated_timestamp, updated_address: cf.updated_address,
                          value: client.send(field.name) }
          sub_task << task_object
        end

        # To update data for `status_board`
        ApiTaskWorker.perform_async('update_task', { group_id: group.id, client_id: client.id })

        checked_in, checked_out = ClientTaskLog.checkin_checkout(user, client)
        is_employee_submitted = client.employees.present?
        task_group = [{ task_id: group.id, is_checked_in: checked_in, is_checked_out: checked_out,
                        is_employee_submitted: is_employee_submitted, checklist_name: group.label,
                        checklist_date: group.created_at.strftime('%Y-%m-%d'), sub_task: sub_task }]

        # Store data of client in client_hash
        client_hash = client.build_client_hash(task_group)
        main_array = []
        main_hash = {}
        main_array << client_hash
        main_hash['client'] = main_array
        api_success(200, 'Tasks successfully updated.', main_hash)
      else
        api_error(400, 'Client not found!')
      end
    else
      api_error(400, 'User not found!')
    end
  end

  # Not required. Only for testing purpose.
  def clear_data
    group_ids = [73, 75, 76, 77, 78, 80]
    sub_task_hash = { 'hq_po_status': '', 'pre_installation_status': '', 'pre_training_status': '',
                      'employee_training_status': '', 'owner_manager_ipos_back_office_training_status': '',
                      'qa_by_pos_management_status': '' }
    Field.where(group_id: group_ids, column_type: 'Checkbox').collect { |f| sub_task_hash[f.name] = '0' }
    client = Client.find_by(id: params[:client_id])
    if client.present?
      client.update_columns(sub_task_hash)
      client.status_board.update(pre_installation_start_date: nil, pre_training_start_date: nil, employee_training_start_date: nil, owner_manager_ipos_back_office_training_start_date: nil,
                                 pre_installation_end_date: nil, pre_training_end_date: nil, employee_training_end_date: nil, owner_manager_ipos_back_office_training_end_date: nil,
                                 qa_by_pos_management_start_date: nil, qa_by_pos_management_end_date: nil, hq_po_start_date: nil, hq_po_end_date: nil)
      ClientField.where(client_id: params[:client_id]).destroy_all
    end
  end

  private

  def find_user(country_code, phone_number)
    user_phone_number = if country_code.to_i != 1
                          country_code.gsub(' ', '+') + phone_number
                        else
                          phone_number
                        end
    User.find_by_phone_no(user_phone_number)
  end

  def task_params
    params.require(:data).permit!
  end

  # def build_client_hash(client, group)
  #   client_hash = {}
  #   client_hash['client_id'] = client.id
  #   client_hash['client_name'] = client.company_name
  #   client_hash['client_created_date'] = client.created_at.strftime('%Y-%m-%d')
  #   client_hash['task_group'] = group
  #   client_hash
  # end

  # def checkin_checkout(_user, client)
  #   ctl = client.client_task_logs.first
  #   [!ctl&.user_checkin_timestamp.blank?, !ctl&.user_checkout_timestamp.blank?]
  # end

  def geo_location(lat, long)
    results = Geocoder.search([lat, long])
    results.first&.address
  end
end
