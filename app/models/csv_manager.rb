class CSVManager

  def initialize(klass, primary_attribute, map)
    @klass = klass
    @primary_attribute = primary_attribute
    @map = map
    @attributes = attributes #todo: use lazy load instead
  end

  def import(file)
    file = open(file.url)
    ActiveRecord::Base.transaction do
      CSV.parse(file, headers: true) do |row|
        begin
          record = @klass.find_or_initialize_by(@primary_attribute => row[@map[@primary_attribute]])
          @map.each do |k, v|
            attribute = @attributes[k]
            if attribute[:reference]
              if row[v] || !attribute[:reference][:options][:optional]
                record.send(attribute[:reference][:setter], attribute[:reference][:klass].reference_import(row[v]))
              else
                record.send(attribute[:reference][:setter], nil)
              end
            else
              record.send(attribute[:setter], row[v])
            end
          end
          record.save
        rescue ActiveRecord::RecordNotFound => e
        end
      end
    end
  end

  def export(records)
    CSV.generate do |csv|
      csv << @map.values
      records.each do |record|
        row = []
        @map.each do |k, v|
          attribute = @attributes[k]
          if attribute[:reference]
            row.push record.send(attribute[:reference][:getter]).try :reference_export
          else
            row.push record.send(attribute[:getter])
          end
        end
        csv << row
      end
    end
  end

  def try_import(file)
    file = open(file.url)
    errors = []
    ActiveRecord::Base.transaction do
      CSV.parse(file, headers: true) do |row|
        begin
          record = @klass.find_or_initialize_by(@primary_attribute => row[@primary_attribute])
          @map.each do |k, v|
            attribute = @attributes[k]
            if attribute[:reference]
              if row[v] || !attribute[:reference][:options][:optional]
                record.send(attribute[:reference][:setter], attribute[:reference][:klass].reference_import(row[v]))
              else
                record.send(attribute[:reference][:setter], nil)
              end
            else
              record.send(attribute[:setter], row[v])
            end
          end
        rescue ActiveRecord::RecordNotFound => e
          errors.push([file.lineno - 1, e.message])
        end
      end
    end
    errors
  end

  def attributes
    field_names = @map.keys
    reflections = @klass.reflect_on_all_associations :belongs_to
    attributes = {}
    field_names.each do |field_name|
      attributes[field_name] = {getter: field_name, setter: field_name+'='}
    end
    reflections.each do |reflection|
      attributes[reflection.name.to_s + '_id'][:reference] = {klass: reflection.klass, getter: reflection.name.to_s, setter: reflection.name.to_s+'=', options: reflection.options}
    end
    attributes
  end
end