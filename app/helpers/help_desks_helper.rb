module HelpDesksHelper

  def help_desk_categories
    Klass.find_by(name: 'HelpDesk').fields.find_by(name: 'category').field_picklist_values.pluck(:value)
  end
end
