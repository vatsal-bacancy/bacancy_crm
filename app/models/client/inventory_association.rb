class Client
  class InventoryAssociation < ApplicationRecord

    scope :ordered, -> { order(created_at: :desc) }

    belongs_to :client
    belongs_to :inventory
    belongs_to :created_by, class_name: 'User'

    validates_uniqueness_of :inventory # Because Only one inventory can be attached to a client at a time

    after_save do
      inventory.set_status_to_assigned_to_client
    end

    after_destroy do
      inventory.set_status_to_available
    end

    def self.sort_by_order_with_category
      all.ordered.includes(inventory: {inventory_group: :category}).group_by{ |inventory_association| inventory_association.inventory.inventory_group.category.title }
    end
  end
end
