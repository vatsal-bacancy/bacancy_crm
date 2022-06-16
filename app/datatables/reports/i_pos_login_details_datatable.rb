class Reports::IPosLoginDetailsDatatable < AjaxDatatablesRails::ActiveRecord

  def initialize(params, options = nil)
    @view = options[:view]
    @client_klass = Client.klass
    @client_fields = {}
    super
  end

  def view_columns
    @view_columns ||= {
      client_company_name: { source: 'Client.company_name' },
      client_user_fullname: { source: "User.#{Client::StatusBoard::Base.client_user_fullname_field_name}" },
      client_ipos_username: { source: 'Client.ipos_username' },
      client_ipos_password: { source: 'Client.ipos_password' },
      client_epx_account_number: { source: 'Client.epx_account_number' },
      client_exp_password: { source: 'Client.epx_password' },
      client_4_part_key: { source: 'Client.4_part_key' },
      client_batch_close_time: { source: 'Client.batch_close_time' }
    }
  end

  def data
    records.map.with_index(1) do |record, i|
      {
        index: i,
        client_company_name: view.link_to(record.company_name, view.client_path(record), class: 'common-link', target: :_blank),
        client_user_fullname: record.user.fullname,
        client_ipos_username: view.render('clients/status_board/text',
                                          client: record,
                                          field: client_field_by(:ipos_username)),
        client_ipos_password: view.render('clients/status_board/text',
                                          client: record,
                                          field: client_field_by(:ipos_password)),
        client_epx_account_number: record.epx_account_number,
        client_exp_password: record.epx_password,
        client_4_part_key: record.send('4_part_key'),
        client_batch_close_time: view.pretty_time(record.batch_close_time)
      }
    end
  end

  def additional_data
    {
      'yadcf_data_client_user_fullname' => User.all_active_users.collect(&:fullname)
    }
  end

  def get_raw_records
    Client.all.joins(:user).includes(:user)
  end

  private

  def client_field_by(field_name)
    @client_fields[field_name] ||= @client_klass.fields.includes(:field_picklist_values).find_by(name: field_name)
  end

  def view
    @view
  end
end
