klass = Klass.find_by(name: "Lead")
lead_default = Group.find_or_create_by(name: "default_group", label: "Lead Details", klass: klass, position: "1", hint: "", default: true)
# lead_address = Group.find_or_create_by(name: "address_group", label: "Address Details", klass: klass, position: "2", hint: "", default: true)

Field.find_or_create_by(name: 'company_name', label: "Company Name", column_type: 'Text', klass: klass, position: 1, head_position: 1, placeholder: "Company Name", min_length: 0, max_length: 255, default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: true, custom: false, group: lead_default, deletable: false, system_field: true )
Field.find_or_create_by(name: 'lead_no', label: "Lead No", column_type: 'Text', klass: klass, head_position: 2, placeholder: "Lead No", min_length: 0, default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, deletable: false, system_field: true)

Field.find_or_create_by(name: 'company_email', label: "Company Email", column_type: 'Email', klass: klass, position: 2, head_position: 3, placeholder: "Company Email", min_length: 0, max_length: 255, default_value: "",  required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: lead_default, deletable: false, system_field: true )


Field.find_or_create_by(name: 'phone_no', label: "Phone No", column_type: 'Phone', klass: klass, position: 3, head_position: 4, placeholder: "Primary Phone", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: lead_default, deletable: false, system_field: true )

field = Field.find_or_create_by(name: 'lead_status', label: "Status", column_type: 'Picklist', klass: klass, position: 4, head_position: 5, placeholder: "Status", min_length: 0, max_length: 255, default_value: "",  required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false,  group: lead_default, have_custom_value: true, system_field: true, deletable: false )

[:pre_qualified, :follow_up, :strong_follow_up, :follow_up_later, :appointment_set, :lost_lead, :closed, :reset].each_with_index do |s, ind|
  field.field_picklist_values.find_or_create_by(value: s.to_s.humanize, position: ind+1)
end

Field.find_or_create_by(name: 'user_id', label: "Assign to", column_type: 'Picklist', klass: klass, position: 5, head_position: 6, placeholder: "Assign to", default_value: "",  required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: lead_default, deletable: false, reference: true, reference_klass: 'User', reference_key: 'first_name' )


Field.find_or_create_by(name: 'description', label: "Description", column_type: 'Text Area HTML', klass: klass, position: 6, placeholder: "Description", min_length: 0, default_value: "",  required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: lead_default )

Field.find_or_create_by(name: 'street_address', label: "Street Address", column_type: 'Text', klass: klass, position: 7, placeholder: "Street Address", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: true, custom: false, group: lead_default,deletable: false )
Field.find_or_create_by(name: 'city', label: "City", column_type: 'Text', klass: klass, position: 8, placeholder: "City", min_length: 0, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: lead_default,deletable: false)
Field.find_or_create_by(name: 'state', label: "State", column_type: 'Text', klass: klass, position: 9, placeholder: "State", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: lead_default,deletable: false )
Field.find_or_create_by(name: 'zip_code', label: "Zip Code", column_type: 'Text', klass: klass, position: 10, placeholder: "Zip Code", min_length: 0, max_length: 255, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: lead_default,deletable: false )
Field.find_or_create_by(name: 'created_at', label: 'Created At', column_type: 'DateTime', klass: klass, position: 11, head_position: 0, placeholder: 'Created At', min_length: nil, max_length: nil, default_value: nil, quick_create: false, key_field_view: true, header_view: false, mass_edit: false, deletable: false, system_field: true, group: lead_default, custom: false, have_custom_value: false)
