klass = Klass.find_by(name: 'Ticket')
ticket_default = Group.find_or_create_by(name: "default_group", label: "Ticket Details", klass: klass, position: "1", hint: "", default: true)

#Field.find_or_create_by(name: 'lead_id', label: 'Lead', column_type: 'Picklist', klass: klass, position: 1, head_position: 1, placeholder: 'Lead', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: ticket_default)

field = Field.find_or_create_by(name: 'category', label: 'Category', column_type: 'Picklist', klass: klass, position: 1, head_position: 1, placeholder: 'Ticket Category', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: ticket_default, have_custom_value: true )
[:small_problem, :big_problem, :emergency].each_with_index do |category, ind|
  field.field_picklist_values.find_or_create_by(value: category.to_s.humanize, position: ind+1)
end

field = Field.find_or_create_by(name: 'priority', label: 'Priority', column_type: 'Picklist', klass: klass, position: 2, head_position: 2, placeholder: 'Ticket Priority', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: ticket_default, have_custom_value: true )
[:low, :normal, :high].each_with_index do |priority, ind|
  field.field_picklist_values.find_or_create_by(value: priority.to_s.humanize, position: ind+1)
end

Field.find_or_create_by(name: 'title', label: 'Title', column_type: 'Text', klass: klass, position: 3, head_position: 3, placeholder: 'Ticket Title', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: ticket_default)

field = Field.find_or_create_by(name: 'status', label: 'Status', column_type: 'Picklist', klass: klass, position: 4, head_position: 4, placeholder: 'Ticket Status', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: ticket_default, have_custom_value: true )
[:open, :close, :in_progress, :wait_for_response, :reopen].each_with_index do |status, ind|
  field.field_picklist_values.find_or_create_by(value: status.to_s.humanize, position: ind+1)
end

Field.find_or_create_by(name: 'description', label: 'Description', column_type: 'Text Area HTML', klass: klass, position: 5, head_position: 5, placeholder: 'Description', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: ticket_default)
Field.find_or_create_by(name: 'ticket_no', label: "Ticket No", column_type: 'Text', klass: klass, head_position: 6, placeholder: "Ticket No", min_length: 0, default_value: "", required: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, deletable: false)
Field.find_or_create_by(name: 'created_at', label: 'Created Date/Time', column_type: 'DateTime', klass: klass, head_position: 7, placeholder: 'Created At', min_length: 0, max_length: 255, default_value: '', key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false )
Field.find_or_create_by(name: 'attachment', label: 'Files', column_type: 'File', klass: klass, position: 6, placeholder: 'Attachment', min_length: 0, max_length: 255, required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: ticket_default)
Field.find_or_create_by(name: 'ticketable_company_name', label: 'Company Name', column_type: 'Text', klass: klass, head_position: 8, placeholder: 'Company Name', min_length: 0, max_length: 255, required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false)
