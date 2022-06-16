klass = Klass.find_by(name: 'EmailTemplete')
email_temp_default = Group.find_or_create_by(name: "default_group", label: "Email Template", klass: klass, position: "1", hint: "", default: true)

Field.find_or_create_by(name: 'name', label: 'Name', column_type: 'Text', klass: klass, position: 1, head_position: 1, placeholder: 'Invoice number', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: email_temp_default)
Field.find_or_create_by(name: 'subject', label: 'Subject', column_type: 'Text', klass: klass, position: 2, head_position: 2, placeholder: 'Customer Name', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: email_temp_default)
field = Field.find_or_create_by(name: 'status', label: 'Status', column_type: 'Picklist', klass: klass, position: 3, head_position: 3, placeholder: 'Order number', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: email_temp_default,have_custom_value: true, system_field: true )

[:public, :private].each_with_index do |s, ind|
  field.field_picklist_values.find_or_create_by(value: s.to_s.humanize, position: ind+1)
end


Field.find_or_create_by(name: 'content', label: 'Content', column_type: 'Text Area HTML', klass: klass, position: 4, head_position: 4, placeholder: 'Invoice date', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: email_temp_default)
Field.find_or_create_by(name: 'attachment', label: '', column_type: 'File', klass: klass, position: 5, head_position: 5, placeholder: 'Due date', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: email_temp_default)

