class VendorDatatable < AjaxDatatablesRails::ActiveRecord
  include Rails.application.routes.url_helpers

  def initialize(params, options = nil)
    @vendors = options[:vendors]
    @fields = options[:fields]
    @fields_picklist_data = options[:fields_picklist_data]
    super
  end

  def view_columns
    @view_columns ||= begin
                        columns = {}.with_indifferent_access
                        fields.each do |field|
                          columns[field.name] = { source: "Vendor.#{field.name}" }
                        end
                        # For date and datetime filtering
                        fields.select{|f| f.is_date_or_date_time? }.each do |field|
                          columns[field.name] = { source: "Vendor.#{field.name}", cond: :date_range, delimiter: '-yadcf_delim-' }
                        end
                        # To handle reference filtering, TODO: and it can be improved by field.reference
                        columns['assigned_to_id'] = { source: "User.fullname" }
                        columns
                      end
  end

  def data
    records.map do |vendor|
      attributes = {}
      attributes[:'checkbox-column'] = ApplicationController.render partial: 'renderer/ajax_datatable/checkbox', locals: { object: vendor }
      attributes[:'action-column'] = ApplicationController.render partial: 'renderer/ajax_datatable/action', locals: { show_path: polymorphic_path(vendor),
                                                                                                                       edit_path: edit_polymorphic_path(vendor) }
      fields.each do |field|
        attributes[field.name] = ApplicationController.render partial: 'renderer/ajax_datatable/field', locals: { object: vendor,
                                                                                                                  field: field,
                                                                                                                  fields_picklist_data: fields_picklist_data }
      end
      attributes
    end
  end

  # for yadcf, for data of picklist and reference user_id
  # TODO: Reference based dropdowns filtering can be improved by field.reference
  def additional_data
    data = {}
    fields.select{|f| f.is_picklist?}.each do |field|
      data["yadcf_data_#{field.name}"] = field.field_picklist_values.pluck(:value)
    end
    data['yadcf_data_assigned_to_id'] = User.all_active_users.collect(&:fullname)
    data
  end

  def get_raw_records
    @vendors.joins(:assigned_to)
  end

  def fields
    @fields
  end

  def fields_picklist_data
    @fields_picklist_data
  end
end
