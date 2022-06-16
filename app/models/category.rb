class Category < ApplicationRecord
  default_scope { order(:title) }

  belongs_to :user, optional: true

  has_many :subcategories, dependent: :destroy
  has_many :inventories, dependent: :destroy
  has_many :inventory_groups, dependent: :destroy

  def reference_export
    title
  end

  def self.reference_import(title)
    self.find_by!(title: title)
  end
end
