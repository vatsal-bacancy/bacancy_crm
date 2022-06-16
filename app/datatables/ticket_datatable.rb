class TicketDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegator :@view, :polymorphic_path
  def_delegator :@view, :edit_polymorphic_path

  def initialize(params, options = nil)
    @objects = options[:objects]
    @fields = options[:fields]
    @fields_picklist_data = options[:fields_picklist_data]
    @view = options[:view]
    super
  end

  def view_columns
    @view_columns ||= begin
                        columns = {}.with_indifferent_access
                        fields.each do |field|
                          columns[field.name] = { source: "Ticket.#{field.name}" }
                        end
                        # For date and datetime filtering
                        fields.select{|f| f.is_date_or_date_time? }.each do |field|
                          columns[field.name] = { source: "Ticket.#{field.name}", cond: :date_range, delimiter: '-yadcf_delim-' }
                        end
                        # To handle reference filtering, TODO: and it can be improved by field.reference
                        # Filtering only support for first_name because fullname is not a column
                        columns[:owner] = { source: 'User.fullname' }
                        columns[:ticket_users] = { source: 'User.fullname', custom_table_name: 'users_tickets' }
                        columns[:ticketable_company_name] = { source: 'Ticket.company_name', cond: polymorphic_search_helper }
                        columns
                      end
  end

  def data
    records.map do |object|
      attributes = {}
      attributes['checkbox-column'] = ApplicationController.render partial: 'renderer/ajax_datatable/checkbox', locals: { object: object }
      attributes['action-column'] = ApplicationController.render partial: 'renderer/ajax_datatable/action', locals: { show_path: polymorphic_path(object),
                                                                                                                       edit_path: edit_polymorphic_path(object) }
      fields.each do |field|
        attributes[field.name] = ApplicationController.render partial: 'renderer/ajax_datatable/field', locals: { object: object,
                                                                                                                  field: field,
                                                                                                                  fields_picklist_data: fields_picklist_data }
      end
      attributes[:owner] = object.owner.fullname
      attributes[:ticket_users] = object.users.collect(&:fullname).join(', ')
      attributes
    end
  end

  # For yadcf picklist
  def additional_data
    data = {}
    fields.select{|f| f.is_picklist?}.each do |field|
      data["yadcf_data_#{field.name}"] = field.field_picklist_values.pluck(:value)
    end
    data["yadcf_data_owner"] = User.all_active_users.collect(&:fullname)
    data["yadcf_data_ticket_users"] = User.all_active_users.collect(&:fullname)
    data
  end

  # Note: Here we are using join of same relation twice (i.e. User)
  # So they uses different table aliases for each
  #  For owner: it will generate by default i.e. `users`
  #  For users: it will generate `users_tickets`
  #  So we need to pass it to `view_columns` method as `custom_table_name`
  def get_raw_records
    @objects.left_joins(:lead, :client).left_joins(:owner, :users).select('users.fullname, users_tickets.fullname, tickets.*').distinct
  end

  private

  def fields
    @fields
  end

  def fields_picklist_data
    @fields_picklist_data
  end

  def polymorphic_search_helper
    -> (column, value) do
      Lead.arel_table[column.field].matches("%#{value}%").or(Client.arel_table[column.field].matches("%#{value}%"))
    end
  end
end
