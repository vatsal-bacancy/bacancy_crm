class ResetPositionOfFieldsAndGroups < ActiveRecord::Migration[5.2]
  def up
    Klass.all.each do |klass|
      klass.groups.each_with_index do |group, position_in_klass|
        group.update(position: position_in_klass)
        group.fields.each_with_index do |field, position_in_group|
          field.update(position: position_in_group)
        end
      end
    end
  end

  def down
  end
end
