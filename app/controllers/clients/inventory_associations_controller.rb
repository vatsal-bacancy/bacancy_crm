# As per http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/
module Clients
  class InventoryAssociationsController < ApplicationController
    before_action :authenticate_user!
    before_action :get_client, only: [:index, :bulk_create]

    def index
    end

    def bulk_new
    end

    def bulk_create
      inventory_ids.each do |inventory_id|
        get_client.inventory_associations.create(inventory_id: inventory_id, created_by: current_user)
      end
    end

    def subcategories
      @category = Category.find(params[:category_id])
    end

    def inventory_groups
      @subcategory = Subcategory.find(params[:subcategory_id])
    end

    def inventory_group
      @inventory_group = InventoryGroup.find(params[:inventory_group_id])
    end

    def inventory_groups_by_sku
      @inventory_groups = InventoryGroup.joins(:inventories).includes(:inventories).merge(Inventory.active).where('inventories.sku ILIKE ?', "%#{params[:sku]}%")
    end

    private

    def get_inventory_association
      @inventory_association ||= if params[:id]
                                   Client::InventoryAssociation.find(params[:id])
                                 else
                                   get_client.inventory_associations.new
                                 end
    end

    def get_client
      @client ||= Client.find(params[:client_id])
    end

    def inventory_ids
      params[:inventory_ids] || []
    end
  end
end
