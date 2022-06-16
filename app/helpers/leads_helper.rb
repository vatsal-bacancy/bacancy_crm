module LeadsHelper

  def check_field_value(field, value)
    re = Regexp.new(Field::PATTERNS[field.column_type.to_sym].to_s).freeze
    (re.match?(value) or field.reference == true or field.column_type == "Picklist") ? "" : "color-red"
  end


  def check_data(data, fields)
    errors = []
    row = []
    data.each_with_index do |row, ind|
      hash = {id: row[0]}
      error_hash = {}
      error_hash[ind+1] = []
      name = row["Assign to"].split(" ") rescue ""
      u = User.find_by(first_name: name[0], last_name: name[1]).try(:id)
      row.delete("Id")
      row.to_h.each do |k,v|
        field = fields.find_by(label: k)
        if field
          hash[field.name] = field.name == 'user_id' ? u : v
        end
      end
      @lead = Lead.find_by(id: hash[:id])
      if @lead.present?
        @lead.assign_attributes(hash)
        @lead.valid?
        error_hash[ind+1]  <<  @lead.errors.details
      else
        @lead = Lead.new(hash)
        @lead.valid?
        error_hash[ind+1]  <<  @lead.errors.details
      end
      errors << error_hash
    end
    errors
  end
end
