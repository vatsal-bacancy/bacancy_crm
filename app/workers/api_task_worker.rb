class ApiTaskWorker
  include Sidekiq::Worker

  def perform(method_name, args = nil)
    send(method_name, args)
  end

  def index_task(args)
    user_fullname = args['user_fullname']
    client_ids = args['client_ids']
    clients = Client.where(id: client_ids)
    fs = Field.where(name: %w[hq_po_assigned_to pre_installation_assigned_to pre_training_assigned_to
                              employee_training_assigned_to owner_manager_ipos_back_office_training_assigned_to qa_by_pos_management_assigned_to])
    fs.each { |f| FieldPicklistValue.find_or_create_by(field_id: f.id, value: user_fullname) }
    clients_to_be_updated = clients.where(hq_po_status: nil).or(clients.where(hq_po_status: ''))
    if clients_to_be_updated.present?
      client_status_boards = Client::StatusBoard::Base.where(client_id: clients_to_be_updated)
      client_status_boards.update_all(hq_po_start_date: Time.now, hq_po_end_date: nil)
      clients_to_be_updated.update_all(hq_po_assigned_to: user_fullname, pre_installation_assigned_to: user_fullname, pre_training_assigned_to: user_fullname, employee_training_assigned_to: user_fullname, owner_manager_ipos_back_office_training_assigned_to: user_fullname, qa_by_pos_management_assigned_to: user_fullname,
                                       hq_po_status: 'In Progress')
    end
    puts '====API Index Task completed===='
  end

  def update_task(args)
    group_id = args['group_id']
    client_id = args['client_id']
    group = Group.find_by(id: group_id)
    client = Client.find_by(id: client_id)
    # Groups showing in Mobile Side
    group_ids = [73, 75, 76, 77, 78, 80]

    if group_ids.include?(group.id)
      client_json = client.as_json
      group_fields = group.fields.where(column_type: ['Checkbox']).pluck(:name)
      response_client = group_fields.collect do |f|
        client_json[f]
      end
      unless response_client.include?('0') || response_client.include?(nil)
        if group.id == 73
          client.status_board.update(hq_po_end_date: Time.now)
          client.update(hq_po_status: 'Completed')
        elsif group.id == 75
          client.status_board.update(pre_installation_end_date: Time.now)
          client.update(pre_installation_status: 'Completed')
        elsif group.id == 76
          client.status_board.update(pre_training_end_date: Time.now)
          client.update(pre_training_status: 'Completed')
        elsif group.id == 77
          client.status_board.update(employee_training_end_date: Time.now)
          client.update(employee_training_status: 'Completed')
        elsif group.id == 78
          client.status_board.update(owner_manager_ipos_back_office_training_end_date: Time.now)
          client.update(owner_manager_ipos_back_office_training_status: 'Completed')
        elsif group.id == 80
          client.status_board.update(qa_by_pos_management_end_date: Time.now)
          client.update(qa_by_pos_management_status: 'Completed')
        end
      end
      puts '====API Update Task completed===='
    end
  end
end
