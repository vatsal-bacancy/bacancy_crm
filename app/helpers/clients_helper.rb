module ClientsHelper
  def self.check_field_value(field, value)
    re = Regexp.new(Field::PATTERNS[field.column_type.to_sym].to_s).freeze
    (re.match?(value) or field.reference == true or field.column_type == "Picklist") ? "" : "color-red"
  end

  def self.check_data(data, fields)
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
      @client = Client.find_by(id: hash[:id])
      if @client.present?
        @client.assign_attributes(hash)
        @client.valid?
        error_hash[ind+1]  <<  @client.errors.details
      else
        @client = Client.new(hash)
        @client.valid?
        error_hash[ind+1]  <<  @client.errors.details
      end
      errors << error_hash
    end
    errors
  end

  # Note: This depends on dynamic fields it could break the application, if deleted
  def client_tier_style(client)
    client_tier = client.client_tier_
    if client_tier.present?
      if client_tier.include? 'TIER 1'
        'background: #FFFF00; color: #545454'
      elsif client_tier.include? 'TIER 2'
        'background: #FFA500; color: #545454'
      elsif client_tier.include? 'TIER 3'
        'background: #ffcccb; color: #545454'
      elsif client_tier.include? 'TIER 4'
        'background: #00FF00; color: #545454'
      elsif client_tier.include? 'TIER 5'
        'background: #304ffe; color: white'
      end
    end
  end

  def client_tier_link_style(client)
    client_tier = client.client_tier_
    if client_tier.present?
      if client_tier.include? 'TIER 1'
        'background: #FFFF00;'
      elsif client_tier.include? 'TIER 2'
        'background: #FFA500;'
      elsif client_tier.include? 'TIER 3'
        'background: #ffcccb;'
      elsif client_tier.include? 'TIER 4'
        'background: #00FF00;'
      elsif client_tier.include? 'TIER 5'
        'background: #304ffe; color: cyan'
      end
    end
  end
end
