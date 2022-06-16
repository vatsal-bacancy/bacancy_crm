klass = Klass.find_by(name: "Project")
project_default = Group.find_or_create_by(name: "default_group", label: "Project Details", klass: klass, position: "1", hint: "", default: true)

Field.find_or_create_by(name: 'name', label: 'Project Name', column_type: 'Text', klass: klass, position: 1, head_position: 1, placeholder: 'Project Name', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: project_default)
field = Field.find_or_create_by(name: 'status', label: 'Project Status', column_type: 'Picklist', klass: klass, position: 2, head_position: 2, placeholder: 'Project Status', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: project_default, have_custom_value: true)
[:complete, :incomplete].each_with_index do |status, ind|
  field.field_picklist_values.find_or_create_by(value: status.to_s.humanize, position: ind+1)
end

Field.find_or_create_by(name: 'start_date', label: 'Start Date', column_type: 'Date', klass: klass, position: 3, head_position: 3, placeholder: 'Start Date', default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: project_default)
Field.find_or_create_by(name: 'end_date', label: 'End Date', column_type: 'Date', klass: klass, position: 4, head_position: 4, placeholder: 'End Date', default_value: '', required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: project_default)
Field.find_or_create_by(name: 'user_id', column_type: 'Hidden',  klass: klass, deletable: false, reference: true, reference_klass: 'user', reference_key: 'first_name', group: project_default)
Field.find_or_create_by(name: 'description', label: 'Description', column_type: 'Text Area HTML', klass: klass, position: 6, head_position: 5, placeholder: 'Description', min_length: 0, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: project_default)

Field.find_or_create_by(name: 'client_id', label: 'Client', column_type: 'Integer',  klass: klass, position: 7, head_position: 6, header_view: true, required: true,  placeholder: 'Client', quick_create: true, key_field_view: true, system_field: true, custom: false,  reference: true,  reference_klass: 'Client',  reference_key: 'company_name', group: project_default)
