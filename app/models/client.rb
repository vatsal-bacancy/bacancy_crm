class Client < ApplicationRecord
  include WorkFlows::Observer
  include Client::StatusBoard::Observer

  audited

  scope :company, -> { where(is_admin: false)}
  scope :assigned_clients, -> { where(lead_status: Client::StatusBoard::Base::CLIENT_STATUS_ACTIVE)&.includes(:client_task_logs, :employees, :fields) }
  scope :assigned_client, ->(client_id) { where(lead_status: Client::StatusBoard::Base::CLIENT_STATUS_ACTIVE, id: client_id)&.includes(:client_task_logs, :employees, :fields) }

  belongs_to :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :tasks, as: :taskable, dependent: :destroy
  has_many :file_manager_file_associations, as: :associable, class_name: 'FileManager::FileAssociation', dependent: :destroy
  has_many :files, through: :file_manager_file_associations
  has_many :cemails, as: :cemailable, dependent: :destroy
  has_many :tickets, as: :ticketable, dependent: :destroy
  has_many :notes, as: :noteable, dependent: :destroy
  has_many :projects, class_name: 'ProjectManagement::Project', dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :lead_client_contacts, as: :contactable, dependent: :destroy
  has_many :contacts, through: :lead_client_contacts
  has_many :meetings, as: :meetingable, class_name: 'Meetings::Meeting', dependent: :destroy
  has_many :inventory_associations, class_name: 'Client::InventoryAssociation', dependent: :destroy
  has_many :purchase_order_versions, as: :purchase_orderable, class_name: 'PurchaseOrder::Version', dependent: :destroy
  has_many :contracts, as: :contractable, class_name: 'Contract::Contract', dependent: :destroy
  has_many :shipments, class_name: 'Client::Shipment', dependent: :destroy
  has_many :client_task_logs, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :client_fields, dependent: :destroy
  has_many :fields, through: :client_fields

  has_one :status_board, class_name: 'Client::StatusBoard::Base', dependent: :destroy

  accepts_nested_attributes_for :contacts

  validates :company_name, uniqueness: true
  # validates :company_email, allow_blank: true, allow_nil: true
  validates_format_of :company_email, allow_blank: true, allow_nil: true, :with => /\A([\w\-\.]+)@([\w\-\.]+)\.([a-zA-Z]{2,5})\z/i,   message: "Please enter validate email"

  validate :menu_approved_by_the_client?, if: -> { menu_us_status_changed? && menu_us_status == 'Completed' }

  after_create :create_client_directory
  before_save :update_user_assigned_at, if: :will_save_change_to_user_id?

  def full_address
    @full_address = "#{street_address} #{city} #{state} #{zip_code}"
  end

  def self.to_csv
    #attributes = %w{company_name lead_no first_name last_name primary_phone secondary_phone primary_email_id secondary_email_id lead_status description user_id}
    #attributes = Lead.column_names
    id_name_label = Field.where(klass_id: Klass.find_by(name: "Client")).where.not(column_type: 'File').pluck(:id,:name,:label).sort
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
      end
    end
  end

  def self.import(file,fields, document_id, user_id)
    errors = []
    ActiveRecord::Base.transaction do
      begin
        convert ={"Id"=> "id", "Lead No" => "lead_no"}.merge(fields)
        count = 0
        create_count = update_count = error_count = 0
        CSV.parse(open(file.url), headers: true, header_converters: lambda { |name| convert[name] }) do |row|
          begin
            count += 1
            id = row["id"]
            lead_picklist = FieldPicklistValue.where(field_id: Field.where(klass_id: Klass.find_by(name: "Client")).find_by(name: "lead_status").id)
            if id
              error_id = ["At #{id}"]
            else
              error_id = ["At line no #{count}"]
            end
            error_details = []

            lead_data = row.to_hash #from csv data
            if Client.exists?(id: id)
              lead_data_table = Client.find(id)
              lead_data.each do |key, value|
                case key
                  when 'user_id'
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
                  when 'lead_status'
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
                  when 'lead_no'
                    klass = Klass.find_by(name: "Client")
                    module_number = klass.module_number
                    lead_data_table.update_attributes(lead_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+lead_data_table.id-1}")
                else
                  if lead_data_table[key] == value
                  else
                    lead_data_table.update_attributes!(key=> value)
                  end
                end
              end
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
                      lead = Client.create row.to_hash  #create lead
                      klass = Klass.find_by(name: "Client")
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
                    lead = Client.new(row.to_hash)
                    if lead.save
                      klass = Klass.find_by(name: "Client")
                      module_number = klass.module_number
                      lead.update_attributes(lead_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+lead.id-1}")
                    else
                      error_details << lead.errors.messages
                    end
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
        klass = Klass.find_by(name: "Client")
        data = { create_count: create_count, update_count: update_count, error_count: error_count}
        ImportDataCsv.create(user_id: user_id, document_id: error_document.id, klass_id:  klass.id, data: data)
        errors = nil

      rescue => e
        # errors << e.message
      end
    end
  end

  def menu_approved_by_the_client?
    unless client_menu_approved == 'Yes' && menu_approval_ip.present? && menu_approval_date_time.present? && menu_approval_address.present?
      errors.add('Menu', 'is not approved by client!')
    end
  end

  GROUP_NAME_VISIBILITY_MAP = {
    'BOARDING' => { status_field: 'boarding_qa_status', visible_if_completed: [] },
    'DUE DILIGENCE' => { status_field: 'due_diligence_status', visible_if_completed: ['BOARDING'] },
    'MENU' => { status_field: 'menu_us_status', visible_if_completed: ['BOARDING'] },
    'INVENTORY' => { status_field: 'inventory_status', visible_if_completed: ['BOARDING'] },
    'DEPLOYMENT' => { status_field: 'deployment_status', visible_if_completed: ['BOARDING', 'DUE DILIGENCE', 'MENU', 'INVENTORY'] }
  }
  GROUP_NAME_VISIBILITY_MAP.default = { status_field: nil, visible_if_completed: [] } # For those groups which are not listed in hash

  def is_department_visible?(group)
    GROUP_NAME_VISIBILITY_MAP[group.name][:visible_if_completed].map { |group_name| is_department_completed?(group_name) }.all?
  end

  DEPARTMENT_COMPLETED_STATUS = 'Completed'

  def is_department_completed?(group_name)
    self.send(GROUP_NAME_VISIBILITY_MAP[group_name][:status_field]) == DEPARTMENT_COMPLETED_STATUS
  end

  def field_picklist_value_of_department(group)
    status_field_name = GROUP_NAME_VISIBILITY_MAP[group.name][:status_field]
    return unless status_field_name # For those groups which are not listed in hash
    group.klass.fields.find_by(name: status_field_name).field_picklist_value_of(self)
  end

  # Note: This depends on dynamic fields it could break the application, if deleted
  def self.merchant_id_attribute
    'nab_merchant_id_mid_'
  end

  # Note: This depends on dynamic fields it could break the application, if deleted
  def merchant_id
    nab_merchant_id_mid_
  end

  def self.klass
    Klass.find_by(name: klass_name)
  end

  def self.klass_name
    'Client'
  end

  def file_fields
    self.class.klass.fields.where(column_type: 'File')
  end

  def create_client_directory
    Directory.create(directoriable: self)
    Directory.create(name: 'system_dir', directoriable: self)
  end

  # TODO:
  #   Warning: In TimeMachine we have to use `json` column type instead of text to store data
  #            So we can use postgres 's JSON query
  def inventory_associations_logs
    TimeMachine::Version.where("serialized_object LIKE ?", "%\"client_id\":#{id},%")
  end

  # Returns `audits` of `client`
  #   It also respects the fields that `Client` model have
  def logs
    @logs ||= begin
                struct = OpenStruct.new
                struct.fields_label_map = Client.klass.fields.pluck(:name, :label).to_h
                struct.records = self.audits.updates.reorder(version: :desc).where('audited_changes ?| array[:keys]', keys: struct.fields_label_map.keys)
                struct
              end
  end

  def to_polymorphic
    "Client:#{id}"
  end

  def update_user_assigned_at
    self.user_assigned_at = Time.now
  end

  def self.build_client_array(task_group, clients, user)
    main_array = []
    clients&.each do |client|
      # Using Blue Print of Task Group
      client_array = Marshal.load(Marshal.dump(task_group))
      checked_in, checked_out = ClientTaskLog.checkin_checkout(user, client)
      is_employee_submitted = client.employees.present?
      client_array.each do |i|
        i['is_checked_in'] = checked_in
        i['is_checked_out'] = checked_out
        i['is_employee_submitted'] = is_employee_submitted
        i['sub_task'].each do |k|
          cf = client.client_fields.find { |client_field| client_field.field_id == k['id'] }
          k['updated_location_latitude'] = cf&.updated_location_latitude
          k['updated_location_longitude'] = cf&.updated_location_longitude
          k['updated_timestamp'] = cf&.updated_timestamp
          k['updated_address'] = cf&.updated_address
          k['value'] = client.send(k['name'])
        end
      end
      # Store data of client in client_hash
      client_hash = client.build_client_hash(client_array)
      main_array << client_hash
    end
    main_array
  end

  def build_client_hash(group)
    client_hash = {}
    client_hash['client_id'] = id
    client_hash['client_name'] = company_name
    client_hash['client_created_date'] = created_at.strftime('%Y-%m-%d')
    client_hash['task_group'] = group
    client_hash
  end
end
