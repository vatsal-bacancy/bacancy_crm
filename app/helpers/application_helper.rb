module ApplicationHelper
  ACTIVE_STRING = 'open active'.freeze
  NOT_ACTIVE_DROPDOWN_STRING = 'collapse'.freeze
  ACTIVE_SUBMENU_ITEM_STRING = 'active-submenu-item'.freeze
  ACTIVE_MENU_ACTIONS = {
    dashboard: [%w[home dashboard]],
    leads: [%w[leads index],
            %w[leads new],
            %w[leads edit],
            %w[leads show],
            %w[contacts lead_contacts],
            %w[contacts edit],
            %w[contacts show]],
    clients: [%w[clients index],
              %w[clients new],
              %w[clients show],
              %w[contacts client_contacts],
              %w[contacts edit],
              %w[clients status_board],
              %w[contacts show]],
    vendors: [%w[vendors index],
              %w[vendors show],
              %w[contacts vendor_contacts]],
    support: [%w[tickets index],
              %w[tickets show]],
    projects: [%w[project_management/projects index],
               %w[project_management/projects show],
               %w[project_management/projects list]],
    file_drive: [%w[directories index],
                 %w[directories system_files]],
    ipos_marketing_tools: [%w[ipos_marketing_tools index]],
    inventory: [%w[inventory_groups index],
                %w[inventory_groups new],
                %w[inventory_groups show],
                %w[categories index]],
    purchase_order: [%w[purchase_order/devices index],
                     %w[purchase_order/devices new],
                     %w[purchase_order/devices edit],
                     %w[purchase_order/devices show],
                     %w[purchase_order/products index],
                     %w[purchase_order/products new],
                     %w[purchase_order/products edit],
                     %w[purchase_order/products show]],
    invoice: [%w[invoices index],
              %w[invoices new],
              %w[invoices show]],
    kpi: [%w[kpis index],
          %w[kpis sales],
          %w[kpis marketing],
          %w[clients status_board],
          %w[tickets reports],
          %w[kpis account_manager_performance],
          %w[kpis show]],
    settings: [%w[settings index],
               %w[settings users_settings],
               %w[settings index],
               %w[users/time_sheet_logs all_users],
               %w[users/time_sheet_logs index],
               %w[users index],
               %w[user_permissions edit],
               %w[roles index],
               %w[roles edit],
               %w[roles new],
               %w[settings module],
               %w[field_picklist_values index],
               %w[module_numbers index],
               %w[work_flows index],
               %w[work_flows new],
               %w[email_templetes index],
               %w[email_templetes new],
               %w[invoice_taxes index],
               %w[settings email],
               %w[contract/templates index],
               %w[contract/templates new],
               %w[users/tfa_phone_numbers index],
               %w[users/time_sheet_logs settings]]}.freeze

  ACTIVE_SUB_MENU_ACTIONS = {
    lead_company: [%w[leads index],
                   %w[leads new],
                   %w[leads edit],
                   %w[leads show]],
    lead_contacts: [%w[contacts lead_contacts],
                    %w[contacts edit],
                    %w[contacts show]],
    client_company: [%w[clients index],
                     %w[clients new],
                     %w[clients show]],
    client_contacts: [%w[contacts client_contacts],
                      %w[contacts edit],
                      %w[contacts show]],
    production_summary: [%w[clients status_board]],
    production_summary_tv: [%w[clients status_board]],
    vendor_company: [%w[vendors index],
                     %w[vendors show]],
    vendor_contacts: [%w[contacts vendor_contacts]],
    tickets: [%w[tickets index],
              %w[tickets show]],
    projects_dashboard: [%w[project_management/projects index],
                         %w[project_management/projects show]],
    projects: [%w[project_management/projects list]],
    file_drive: [%w[directories index]],
    system_files: [%w[directories system_files]],
    marketplace: [%w[ipos_marketing_tools index]],
    inventory_groups: [%w[inventory_groups index],
                       %w[inventory_groups new],
                       %w[inventory_groups show]],
    category_management: [%w[categories index]],
    devices: [%w[purchase_order/devices index],
              %w[purchase_order/devices new],
              %w[purchase_order/devices edit],
              %w[purchase_order/devices show]],
    products: [%w[purchase_order/products index],
               %w[purchase_order/products new],
               %w[purchase_order/products edit],
               %w[purchase_order/products show]],
    invoices: [%w[invoices index],
               %w[invoices new],
               %w[invoices show]],
    sales_kpi: [%w[kpis sales]],
    marketing_kpi: [%w[kpis marketing]],
    product_support_kpi: [%w[clients status_board]],
    ticket_report: [%w[tickets reports]],
    account_manager_performance: [%w[kpis account_manager_performance]],
    crm_settings: [%w[settings index],
                   %w[settings users_settings],
                   %w[settings index],
                   %w[users/time_sheet_logs all_users],
                   %w[users/time_sheet_logs index],
                   %w[users index],
                   %w[user_permissions edit],
                   %w[roles index],
                   %w[roles edit],
                   %w[roles new],
                   %w[settings module],
                   %w[field_picklist_values index],
                   %w[module_numbers index],
                   %w[work_flows index],
                   %w[work_flows new],
                   %w[email_templetes index],
                   %w[email_templetes new],
                   %w[invoice_taxes index],
                   %w[settings email],
                   %w[contract/templates index],
                   %w[contract/templates new],
                   %w[users/tfa_phone_numbers index],
                   %w[users/time_sheet_logs settings]]}.freeze

  def active_menu_class(menu_text)
    unless ACTIVE_MENU_ACTIONS[menu_text].present? && ACTIVE_MENU_ACTIONS[menu_text].include?([params[:controller], params[:action]])
      return
    end

    ACTIVE_STRING
  end

  def active_menu_dropdown_class(menu_text)
    unless ACTIVE_MENU_ACTIONS[menu_text].present? && ACTIVE_MENU_ACTIONS[menu_text].include?([params[:controller], params[:action]])
      return NOT_ACTIVE_DROPDOWN_STRING
    end
  end

  def active_submenu_item_class(submenu_item)
    unless ACTIVE_SUB_MENU_ACTIONS[submenu_item].present? && ACTIVE_SUB_MENU_ACTIONS[submenu_item].include?([params[:controller], params[:action]])
      return
    end

    ACTIVE_SUBMENU_ITEM_STRING
  end

  def active_submenu_production_item_class(submenu_item)
    unless ACTIVE_SUB_MENU_ACTIONS[submenu_item].present? && ACTIVE_SUB_MENU_ACTIONS[submenu_item].include?([params[:controller], params[:action]])
      return
    end

    return if params[:tv] != 'true' && submenu_item == :production_summary_tv
    return if params[:tv] == 'true' && submenu_item == :production_summary

    ACTIVE_SUBMENU_ITEM_STRING
  end

  def error_message(object, field, options = {})
    content_tag(:div, object.errors.full_message(field, object.errors[field].join('')), class: options) if (object.errors.present? && object.errors[field].present?)
  end

  def format_float(val)
    sprintf '%.2f', val.to_f
  end

  def time_date(date)
    if date.year > Time.now.year
      date.strftime('%d/%m/%y')
    else
      date.to_date == Time.now.to_date ? date.strftime('%l:%M %P') : date.strftime('%b %d')
    end
  end

  def display_two_digit(amount)
    amount = amount.kind_of?(Float) ? amount : amount.to_f
    amount = (amount < 0) ? 0 : amount
    '%.2f' % amount
  end

  def pretty_days_from_float(days)
    if days.present?
      "#{days.to_i} Days"
    else
      '-'
    end
  end

  def pretty_days_from_dates(start_date, end_date)
    if start_date.present? && end_date.present?
      "#{(end_date.to_date - start_date.to_date).to_i} Days"
    else
      '-'
    end
  end

  def pretty_hours_from_number(number)
    return unless number.present?
    minutes = (number / 60) % 60
    hours = number / (60 * 60)
    format('%02d:%02d', hours, minutes)
  end

  def parse_multi_select(serialized)
    serialized ||= "[]"
    JSON.parse(serialized).join(', ')
  end

  def pretty_amount(amount)
    '$%.2f' % amount.to_f
  end

  def pretty_date_time(date_time)
    date_time.try(:strftime, '%m/%d/%Y, %I:%M %p')
  end

  def pretty_date(date)
    date.try(:strftime, '%m/%d/%Y')
  end

  def pretty_time(time)
    time.try(:strftime, '%l:%M %p')
  end

  def pretty_reference(field, object)
    if (id = object.send(field.name)) # To avoid issue with relations having `optional: true`
      field.reference_klass.constantize.find(id).send(field.reference_key)
    end
  end

  # TODO: FIXME: `nil` will also considered as `NO`
  # We should set default value to false
  # Checkbox column is `text`, See Field::TYPE_CAST for more
  def pretty_checkbox(value)
    return 'Yes' if value == '1' || value == 't' || value == 'true' || value == true
    return 'No'
  end

  # TODO: should be moved to decorator / pretty renderer
  def pretty_file_associations(file_associations)
    return unless file_associations.present?
    str = '<div class="col-md-12">'
    file_associations.each do |file_association|
      str += link_to file_association.file.attachment.url, target: :_blank, class: 'common-link' do
        "<i class='fa fa-file' aria-hidden='true'></i> #{file_association.file.attachment.file.filename.truncate(20)}".html_safe
      end
    end
    str += '</div>'
    str.html_safe
  end

  def render_field(field, object)
    return pretty_date(object.send(field.name)) if field.column_type == 'Date'
    return pretty_time(object.send(field.name)) if field.column_type == 'Time'
    return pretty_date_time(object.send(field.name)) if field.column_type == 'DateTime'
    return '<p></p>'.html_safe if field.column_type == 'Label'
    return parse_multi_select(object.send(field.name)) if field.column_type == 'Multi-Select Check Box'
    return "<a href='#{object.send(field.name)}' target='_blank'>#{object.send(field.name)}</a>".html_safe if field.column_type == 'URL'
    return "<iframe srcdoc='#{object.send(field.name)}'></iframe>".html_safe if field.column_type == 'Text Area HTML'
    return pretty_checkbox(object.send(field.name)) if field.column_type == 'Checkbox'
    return pretty_file_associations(object.file_manager_file_associations.where(field: field)) if field.column_type == 'File'
    return object.user.fullname if field.name == 'user_id'
    return pretty_reference(field, object) if field.reference?
    return object.send(field.name) # render common fields
  end

  def pretty_value(field, object)
    value = render_field(field, object)
    return value.present? ? value : 'N/A'
  end

  # returns fields option for given klass for options tag
  def fields_by_klass_for_options(klass)
    if klass.present?
      return klass.groups.select(:id, :label).map { |group|
        [group.label, group.fields.select(:column_type, :label, :id).map do |field|
          field_array = [field.label, field.id]
          field_array.push({ "data-is-picklist": true, "data-picklist-values": field.field_picklist_values.pluck(:value).to_json }) if field.is_picklist?
          field_array
        end
        ]
      }
    end
    []
  end

  def url_simplifier(url)
    (url.start_with?('http://') || url.start_with?('https://')) ? url : "http://#{url}"
  end

  def geo_location(lat, long)
    results = Geocoder.search([lat, long])
    results.first&.address
  end
end
