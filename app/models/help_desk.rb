class HelpDesk < ApplicationRecord

  # TODO: Use relation instead
  def self.all_with_category
    with_categories = {}
    all.each do |help_desk|
      if with_categories[help_desk.category].present?
        with_categories[help_desk.category].push(help_desk)
      else
        with_categories[help_desk.category] = [help_desk]
      end
    end
    with_categories
  end
end
