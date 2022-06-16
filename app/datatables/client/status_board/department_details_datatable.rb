class Client::StatusBoard::DepartmentDetailsDatatable < AjaxDatatablesRails::ActiveRecord

  def initialize(params, options)
    @view = options[:view]
    @client_klass = Client.klass
    @client_fields = {}
    super
  end

  def view_columns
    @view_columns ||= begin
                        columns = {
                          client_company_details: { source: "Client.#{Client::StatusBoard::Base.client_company_name_field_name}" },
                          client_ipos_agent_name: { source: "Client.#{Client::StatusBoard::Base.ipos_agent_field_name}" },
                          client_user_fullname: { source: "User.#{Client::StatusBoard::Base.client_user_fullname_field_name}" }
                        }
                        Client::StatusBoard::Base::DEPARTMENTS.each do |department, fields|
                          columns[department] = { source: "Client.#{fields[:status_field]}" }
                        end
                        columns
                      end
  end

  def data
    records.map.with_index(1) do |record, i|
      attributes = {
        client_company_details: "<div class='client-detail'>
                                  <p>Business Name</p>
                                  <h4>#{view.link_to(record.client_company_name, view.client_path(record.client), class: 'common-link', target: :_blank)}</h4>
                                </div>
                                <div class='client-detail'>
                                  <p>Account Setup Date</p>
                                  <h4>#{view.pretty_date_time record.client_created_at}</h4>
                                </div>
                                <div class='client-detail'>
                                  <p>State</p>
                                  <h4>#{record.client_state}</h4>
                                </div>
                                <div class='client-detail'>
                                  <p>Account Status</p>
                                  <h4>#{view.render('clients/status_board/form',
                                                    client: record.client,
                                                    field: client_field(Client::StatusBoard::Base.client_account_status_field_name))}</h4>
                                </div>
                                <div class='client-detail'>
                                  <p>iPos Username</p>
                                  <h4>#{view.render('clients/status_board/form',
                                                    client: record.client,
                                                    field: client_field(Client::StatusBoard::Base.client_ipos_username_field_name))}</h4>
                                </div>
                                <div class='client-detail'>
                                  <p>iPos Password</p>
                                  <h4>#{view.render('clients/status_board/form',
                                                    client: record.client,
                                                    field: client_field(Client::StatusBoard::Base.client_ipos_password_field_name))}</h4>
                                </div>".html_safe,
        client_ipos_agent_name: view.render('clients/status_board/form',
                                            client: record.client,
                                            field: client_field(Client::StatusBoard::Base.ipos_agent_field_name)),
        client_user_fullname: view.render('clients/status_board/form',
                                          client: record.client,
                                          field: client_field(Client::StatusBoard::Base.client_user_id_field_name)),
        time_taken_by_department: "<div class='table-box bg-lightgray text-center d-flex align-items-center'>
                                    <div class='date-area'>
                                      <p class='text-darkgray'><span>No of days since<br/>
                                      boarding QA Done :</span></p>
                                      <h5 class='day-title #{record.late_time_taken_by_departments? ? 'text-red' : 'text-green' } fw-600'>#{record.pretty_time_taken_by_departments}</h5>
                                    </div>
                                  </div>".html_safe
      }
      Client::StatusBoard::Base::DEPARTMENTS.each do |department, fields|
        attributes[department] = unless record.skip_department?(department)
                                   view.render('clients/status_board/department',
                                               record: record,
                                               assigned_to_field: client_field(fields[:assigned_to_field]),
                                               status_field: client_field(fields[:status_field]),
                                               start_date: record.send(fields[:start_date_field]),
                                               end_date: record.send(fields[:end_date_field]))
                                 end
      end
      attributes
    end
  end

  def additional_data
    data = {
      'yadcf_data_client_ipos_agent_name' => client_field(Client::StatusBoard::Base.ipos_agent_field_name).field_picklist_values.pluck(:value),
      'yadcf_data_client_user_fullname' => User.all_active_users.collect(&:fullname)
    }
    Client::StatusBoard::Base::DEPARTMENTS.each do |department, fields|
      data["yadcf_data_#{department}"] = client_field(fields[:status_field]).field_picklist_values.pluck(:value)
    end
    data
  end

  def get_raw_records
    Client::StatusBoard::Base.all.joins(client: :user).includes(client: :user).active.ordered
  end

  private

  def client_field(field_name)
    @client_fields[field_name] ||= @client_klass.fields.includes(:field_picklist_values).find_by(name: field_name)
  end

  def view
    @view
  end
end
