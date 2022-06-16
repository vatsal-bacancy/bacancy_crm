module InventoriesHelper
  def inventories_array
    Inventory.pluck(:name, :id)
  end

  def tax_array
    InvoiceTax.all.map{ |tax| ["#{tax.name} (#{tax.tax_amount}%)", tax.tax_amount ] }
  end

  def parse_nil(val)
    val ? val : 'N/A'
  end

  def self.check_data(str)
    attributes = Inventory.attributes_array
    errors = []
    CSV.parse(str, headers: true) do |row|
      begin
        ActiveRecord::Base.transaction do
          record = Inventory.find_or_create_by(id: row['Id'])
          attributes.each do |k, v|
            if v[:reference]
              record.send(v[:reference][:setter], v[:reference][:klass].reference_import(row[k]))
            else
              record.send(v[:setter], row[k])
            end
          end
        end
      rescue ActiveRecord::RecordNotFound => exception
        errors.push(exception)
      end
    end
    errors
  end
end
