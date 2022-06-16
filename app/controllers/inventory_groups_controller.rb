class InventoryGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory_group, only: %i[edit update destroy show]
  skip_before_action :verify_authenticity_token, only: %i[setup_inventory_versions]  
  
  def index
    @inventory_groups = InventoryGroup.all.includes(:category, :subcategory)
  end

  def edit
    @inventory_group.inventory_group_options.build if @inventory_group.inventory_group_options.blank?
  end

  def new
    @inventory_group = InventoryGroup.new
    @inventory_group.inventory_group_options.build
    @inventory_group.inventories.build
  end

  def show
    @inventory_groups = InventoryGroup.all
  end

  def destroy_all
    InventoryGroup.where(id: params[:inventory_group_ids]).destroy_all
    @inventory_groups = InventoryGroup.all
    flash[:success] = 'Selected inventory groups deleted successfully.'
  end

  def setup_inventory_versions
    @inventory_group = if params[:inventory_group_id].present? 
        InventoryGroup.find(params[:inventory_group_id]) 
      else
        InventoryGroup.new(inventory_group_params.except(:inventories_attributes))
     end

    options_attributes = inventory_group_params[:inventory_group_options_attributes].to_h.collect do |key, value|
      value[:options] if value[:_destroy] != '1'
    end
    options_attributes = options_attributes.select(&:present?)
    all_combinations = [[]]
    options_attributes.each do |options_attribute|
      all_combinations = combination(all_combinations, options_attribute)
    end
    all_combinations = all_combinations.collect{|a| a.flatten}.select{|a| a.length == options_attributes.count}.uniq
    inventories = @inventory_group.inventories

    all_combinations.uniq.each do |all_combination|
      item_name = "#{@inventory_group.name} #{all_combination.join('/')}".strip
      @inventory_group.inventories.build(name: item_name) if @inventory_group.inventories.where(name: item_name).blank?
    end
  end

  def destroy
  end

  def update
    if @inventory_group.update(inventory_group_params)
      flash[:success] = "Inventory Group updated successfully"
      respond_to do |wants|
        wants.html do
          redirect_to inventory_group_path(@inventory_group)
        end
        wants.js do
          @inventory_groups = InventoryGroup.all.includes(:category, :subcategory)
        end
      end
    else
      flash[:danger] = @inventory_group.errors.full_messages.join(', ')
      render :edit
    end
  end

  def create
    @inventory_group = current_user.inventory_groups.new(inventory_group_params)
    if @inventory_group.save
      flash[:success] = "Inventory Group created successfully"
      redirect_to inventory_groups_path
    else
      flash[:danger] = @inventory_group.errors.full_messages.join(', ')
      render :new
    end
  end

  def subcategories_for_category
    @category = Category.find(params[:id])
  end

  private

  def inventory_group_params
    inventory_group = params.require(:inventory_group)
    inventory_group[:inventory_group_options_attributes].each do |key, value|
      value[:options] = value[:options].split(',').collect(&:strip) if value[:options].kind_of?(String)
      inventory_group[key] = value
    end if inventory_group[:inventory_group_options_attributes]
    inventory_group[:inventories_attributes].each do |inventory_key, inventory_hash|
      InventoryGroup::COMMON_INVENTORY_PARAMS.each do |key|
        inventory_hash[key] = inventory_group[key]
      end
      inventory_group[:inventories_attributes][inventory_key] = inventory_hash
    end if inventory_group[:inventories_attributes]
    inventory_group.permit(InventoryGroup::PERMITTED_PARAMS)
  end

  def set_inventory_group
    @inventory_group = InventoryGroup.find(params[:id])
  end

  def combination(main_array, array_to_compare)
    result = []
    main_array.each do |main_array_elemnt|
      result << main_array_elemnt
      array_to_compare.each do |array_to_compare_element|
        result << [main_array_elemnt, array_to_compare_element]
      end
    end
    result
  end
end

