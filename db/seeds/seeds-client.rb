klass = Klass.find_by(name: "Client")
company_info = Group.find_or_create_by(name: "company_info", label: "Company Information", klass: klass, position: "1", hint: "", default: true)
#default_group = Group.find_or_create_by(name: "default_group", label: "Default", klass: klass, position: "2", hint: "", default: true)

Field.find_or_create_by(name: "company_name", label: "Company Name" ,column_type: "Text" , klass: klass, position: 1, head_position: 1, placeholder: "Company Name", min_length: 0, max_length: 255, default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: company_info, deletable: false, system_field: true )

Field.find_or_create_by(name: 'lead_no', label: "Lead No", column_type: 'Text', klass: klass, placeholder: "Lead No", min_length: 0, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, custom: false, mass_edit: false, deletable: false )

Field.find_or_create_by(name: "company_url", label: "Website URL" ,column_type: "Text" , klass: klass, position: 2, head_position: 2, placeholder: "Website URL", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: company_info, deletable: false, system_field: true )

Field.find_or_create_by(name: 'company_email', label: "Company Email", column_type: 'Email', klass: klass, position: 3, head_position: 3, placeholder: "Company Email", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: company_info, deletable: false )

Field.find_or_create_by(name: 'phone_no', label: "Phone No", column_type: 'Phone', klass: klass, position: 4, head_position: 4, placeholder: "Phone No", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: company_info, deletable: false )

Field.find_or_create_by(name: 'user_id', label: "Assign to", column_type: 'Picklist', klass: klass, position: 5, head_position: 5, placeholder: "Assign to", default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: company_info, deletable: false, reference: true, reference_klass: 'User', reference_key: 'first_name' )

field = Field.find_or_create_by(name: 'lead_status', label: "Status", column_type: 'Picklist', klass: klass, position: 6, head_position: 6, placeholder: "Status", min_length: 0, max_length: 255, default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: company_info, have_custom_value: true, deletable: false )

[:pre_qualified, :follow_up, :strong_follow_up, :follow_up_later, :appointment_set, :lost_lead, :closed, :reset].each_with_index do |s, ind|
  field.field_picklist_values.find_or_create_by(value: s.to_s.humanize, position: ind+1)
end

Field.find_or_create_by(name: 'description', label: "Description", column_type: 'Text Area HTML', klass: klass, position: 7, placeholder: "Description", min_length: 0, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: company_info )

Field.find_or_create_by(name: 'street_address', label: "Company Address", column_type: 'Text', klass: klass, position: 8, placeholder: "Company Address", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: true, custom: false, group: company_info,deletable: false, system_field: true )

Field.find_or_create_by(name: 'city', label: "City", column_type: 'Text', klass: klass, position: 9, placeholder: "City", min_length: 0, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: company_info, deletable: false)

Field.find_or_create_by(name: 'state', label: "State", column_type: 'Text', klass: klass, position: 10, placeholder: "State", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: company_info,deletable: false)

Field.find_or_create_by(name: 'zip_code', label: "Zip Code", column_type: 'Text', klass: klass, position: 11, placeholder: "Zip Code", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: company_info,deletable: false )

Field.find_or_create_by(name: 'created_at', label: 'Created At', column_type: 'DateTime', klass: klass, position: 11, head_position: 0, placeholder: 'Created At', min_length: nil, max_length: nil, default_value: nil, quick_create: false, key_field_view: true, header_view: false, mass_edit: false, deletable: false, system_field: true, group: company_info, custom: false, have_custom_value: false)
