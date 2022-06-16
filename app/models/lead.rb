class Lead < ApplicationRecord
  include WorkFlows::Observer

  audited

  belongs_to :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :tasks, as: :taskable, dependent: :destroy
  has_many :notes, as: :noteable, dependent: :destroy
  has_many :tickets, as: :ticketable, dependent: :destroy
  has_many :cemails, as: :cemailable, dependent: :destroy
  has_many :file_manager_file_associations, as: :associable, class_name: 'FileManager::FileAssociation', dependent: :destroy
  has_many :files, through: :file_manager_file_associations
  has_many :lead_client_contacts, as: :contactable, dependent: :destroy
  has_many :contacts, through: :lead_client_contacts, dependent: :destroy
  has_many :meetings, as: :meetingable, class_name: 'Meetings::Meeting', dependent: :destroy
  has_many :purchase_order_versions, as: :purchase_orderable, class_name: 'PurchaseOrder::Version', dependent: :destroy
  has_many :contracts, as: :contractable, class_name: 'Contract::Contract', dependent: :destroy

  accepts_nested_attributes_for :contacts

  validates :company_email, uniqueness: true, allow_blank: true, allow_nil: true
  validates :company_name, uniqueness: true
  validates_format_of :company_email , uniqueness: true, allow_blank: true, allow_nil: true, :with => /\A([\w\-\.]+)@([\w\-\.]+)\.([a-zA-Z]{2,5})\z/i,   message: "Please enter validate email"

  def self.to_csv
    #attributes = %w{company_name lead_no first_name last_name primary_phone secondary_phone primary_email_id secondary_email_id lead_status description user_id}
    #attributes = Lead.column_names
    id_name_label = Field.where(klass_id: Klass.find_by(name: "Lead")).where.not(column_type: 'File').pluck(:id,:name,:label).sort
    labels = ["Id"]
    attributes = ["id"]
    id_name_label.each do |data|
      attributes << data[1]
      labels << data[2]
    end
    #labels = Field.where(klass_name: "Lead").pluck(:label) #lable as first row in export csv
    #attributes = Field.where(klass_name: "Lead").pluck(:name) #find data by column name
    CSV.generate(headers: true) do |csv|
      csv << labels #create rows
      all.each do |obj|
        csv << attributes.map do |attr|
          if attr == "user_id"
            [ User.find(obj.send(attr)).first_name, User.find(obj.send(attr)).last_name ].join(" ")
          else
            obj.send(attr)
          end
        end
        # csv << q
      end
    end
  end

  def self.import(file, fields, document_id, user_id)
    errors = []
    # convert ={"Id"=> "id" ,"Company Name"=> 'company_name' ,"Lead No" => "lead_no","First Name"=>"first_name",
    #           "Last Name"=>"last_name","Primary Phone"=>"primary_phone","Secondary Phone"=>"secondary_phone",
    #           "Primary Email"=>"primary_email","Secondary Email"=>"secondary_email","Lead Status"=>"lead_status",
    #           "Description"=>"description","Assign to"=>"user_id","Street Address"=>"street_address",
    #           "City"=>"city","State"=>"state","Zip Code"=>"zip_code"}
    ActiveRecord::Base.transaction do
      begin
        convert ={"Id"=> "id", "Lead No" => "lead_no"}.merge(fields)
        count = 0
        create_count = update_count = error_count = 0
        CSV.parse(open(file.url), headers: true, header_converters: lambda { |name| convert[name] }) do |row|
          begin
            # CSV.foreach(file.url, headers: true, header_converters: lambda { |name| convert[name] }) do |row|
            #current user as assign_to
            #Field.where(label: "row").where(klass_id: Klass.find_by(name: "Lead"))
            #row["user_id"] = id
            #Lead.create row.to_hash
            #enter fullname in csv as assign_to
            count += 1
            id = row["id"]
            lead_picklist = FieldPicklistValue.where(field_id: Field.where(klass_id: Klass.find_by(name: "Lead")).find_by(name: "lead_status").id)
            if id
              error_id = ["At #{id}"]
            else
              error_id = ["At line no #{count}"]
            end
            error_details = []

            lead_data = row.to_hash #from csv data
            if Lead.exists?(id: id)
              lead_data_table = Lead.find(id) #form lead table
              lead_data.each do |key,value|
                case key
                  when "user_id"
                    name_email = row["user_id"] #write value
                    name = row["user_id"] #write value
                    if name_email.include?('@') && name_email.include?('.')
                      if User.exists?(email: name_email)
                        #search by email
                        lead_data_table[key] = User.find_by(email: name_email).id
                        lead_data_table.save #update user_id
                      else
                        #error msg
                        error_details << "user must exists"
                        error_count += 1
                      end
                    else
                      #search by full name
                      user_name_all = User.pluck(:id,:first_name,:last_name)

                      user_name_all.each do |user_data|
                        user_full_name = [user_data[1],user_data[2]].join(" ")
                        if user_full_name == name
                          #row["user_id"] = user_data[0]
                          lead_data_table[key] = user_data[0]
                          lead_data_table.save  #update user_id
                          break
                        else
                          #error msg
                          error_details << "user must exists"
                        end
                      end
                    end
                  when "lead_status"
                    #lead_picklist = FieldPicklistValue.where(field_id: Field.where(klass_id: Klass.find_by(name: "Lead")).find_by(name: "lead_status").id)
                    if lead_data_table[key] == lead_data[key] #lead_data[key] == value
                    else
                      if lead_picklist.exists?(value: lead_data[key]) #lead_data[key] == value
                        lead_data_table[key] =  lead_data[key] #lead_data[key] == value
                        lead_data_table.save  #update lead status
                      else
                        #error msg
                        error_details << "lead status must exists"
                      end
                    end
                  when "lead_no"
                    klass = Klass.find_by(name: "Lead")
                    module_number = klass.module_number
                    lead_data_table.update_attributes(lead_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+lead_data_table.id-1}")
                else
                  if lead_data_table[key] == value
                  else
                    lead_data_table.update_attributes!(key=> value)
                  end
                end

              end

              #error join
              if  error_details.present?
                error_id << error_details.join(",")
                errors << error_id.join(" ")
                error_count += 1
              else
                update_count += 1
              end
            else
              row["id"] = nil
              #Lead.joins(:audits).where(:audits=> {auditable_id: id}) ==> id exists show record if not show []
              #if Audited.exists?(auditable_id: id, auditable_type: "Lead", action: "Create")
              name_email = row["user_id"] #write value
              name = row["user_id"] #write value
              if name_email.include?('@') && name_email.include?('.')
                if User.exists?(email: name_email)
                  #search by email
                  row["user_id"] = User.find_by(email: name_email).id
                    if lead_picklist.exists?(value: row["lead_status"]) #lead_data[key] == value
                      lead = Lead.create row.to_hash  #create lead
                      klass = Klass.find_by(name: "Lead")
                      module_number = klass.module_number
                      lead.update_attributes(lead_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+lead.id-1}")
                    else
                      #error msg lead_status must exists
                      error_details << "lead status must exists"
                    end
                else
                  #error user don't exists
                  error_details << "user must exists"
                end
              else
                #search by full name

                user_name_all = User.pluck(:id,:first_name,:last_name)
                user_name_all.each do |user_data|
                  row.delete("id")

                  user_full_name = [user_data[1],user_data[2]].join(" ")
                  if user_full_name == name
                    row["user_id"] = user_data[0]
                    lead = Lead.create! row.to_hash  #create lead
                    klass = Klass.find_by(name: "Lead")
                    module_number = klass.module_number
                    lead.update_attributes(lead_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+lead.id-1}")
                    break
                  else
                    #error user don't exists
                    error_details << "user must exists"
                  end
                end
                #error join
                if  error_details.present?
                  error_id << error_details.join(",")
                  errors << error_id.join(" ")
                  error_count += 1
                else
                  create_count += 1
                end
              end
            end
          rescue => e
            errors << [count, e.message]
            error_count += 1
            next
          end
        end

        csv_data = CSV.generate do |csv|
          cols = ["Row", "Errors"]
          csv << cols
          errors.each do |error|
            csv << error
          end
        end

        @filename = "data-#{Time.now.to_s}"
        file = File.open(Rails.root.join("tmp/#{@filename }.csv"), 'w')
        file.write(csv_data)
        error_document = Document.create(documentable_type: "Document", documentable_id: document_id, user_id: user_id, attachment: file)
        klass = Klass.find_by(name: "Lead")
        data = { create_count: create_count, update_count: update_count, error_count: error_count}
        ImportDataCsv.create(user_id: user_id, document_id: error_document.id, klass_id:  klass.id, data: data)
        errors = nil

      rescue
        # errors << e.message

      end
    end
  end

  def file_fields
    Klass.find_by(name: 'Lead').fields.where(column_type: 'File')
  end

  def to_polymorphic
    "Lead:#{id}"
  end

  def purchase_order_generated?
    purchase_order_versions.count > 0
  end

  def client_menu_uploaded?
    file_manager_file_associations.where(field: Klass.find_by(name: 'Lead').fields.find_by(name: 'upload_client_menu')).present?
  end

  # TODO: We can remove hard coded `upload_client_menu` after adding required validation on dynamic file field
  #   Note: This depends on dynamic fields so if deleted then it could break the application
  # Validates that Lead should have '1 contacts, Work order, upload_client_menu present or not', to get converted to Client
  def validate_for_client_conversion
    base_errors = []
    if contacts.size < 1
      base_errors << ' at least 1 contact'
    end
    if !purchase_order_generated?
      base_errors << ' Purchase order'
    end
    if !client_menu_uploaded?
      base_errors << ' Client menu file'
    end
    if base_errors.present?
      errors[:base] << 'This lead should have' + base_errors.join(',') + ' present!'
    end
  end

  def full_address
    @full_address = "#{street_address} #{city} #{state} #{zip_code}"
  end
end
