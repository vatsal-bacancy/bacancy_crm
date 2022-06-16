class InventoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]
  before_action :set_klass, only: [:new, :edit,:show]
  skip_before_action :verify_authenticity_token, only: %i[update_inventory_column]


  def index
    @klass = Klass.find_by(name: 'Inventory')
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    can_perform?(@klass, @action_read)
    @inventories = Inventory.all
    respond_to do |format|
      format.js
      format.html
      format.csv{send_data Inventory.export, filename: "inventories-#{Date.today}.csv"}
    end
  end

  def show
    @inventories = Inventory.all
  end

  def new
    inventory_group = InventoryGroup.find(params[:inventory_group_id])
    @inventory = Inventory.new(inventory_group: inventory_group, name: inventory_group.name)
  end

  def edit
    @data = {}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def update_inventory_column
    inventories = Inventory.where(id: params[:inventory_ids])
    inventories.update_all({params[:column] => params[:value]})
    flash[:success] = "#{inventories.count} inventories updated."
  end

  def create
    @inventory = current_user.inventories.new(inventory_params)
    @inventory.available_quantity = @inventory.initial_quantity
    @inventory.available_value = @inventory.initial_value
    if @inventory.save
      @inventory.create_attachments(@company, current_user, params[:attachments])
      flash[:success] = "Inventory created successfully."
    else
      flash[:danger] = @inventory.errors.full_messages.join(', ')
    end
    redirect_to inventory_group_path(@inventory.inventory_group)
  end

  def update
    if @inventory.update(inventory_params)
      @inventory.create_attachments(@company, current_user, params[:attachments])
      flash[:success] = 'Inventory was successfully updated.'
    else
      flash[:danger] = @inventory.errors.full_messages.join(', ')
    end
    respond_to do |format|
      format.js
      format.html { redirect_to inventory_group_path(@inventory.inventory_group) }
    end
  end

  def destroy
    @inventory = Inventory.find(params[:id])
    @inventory.destroy
    @klass = Klass.find_by(name: 'Inventory')
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    can_perform?(@klass, @action_delete)
    @inventories = Inventory.all
    redirect_to inventory_group_path(@inventory.inventory_group)
  end

  def destroy_all
    @inventories = Inventory.where(id: params[:ids])
    if @inventories.destroy_all
      flash[:success] = 'Successfully destroyed selected inventories'
    else
      flash[:danger] = 'Unable to destroy selected inventories'
    end
    redirect_to inventories_path
  end

  def subcategories_for_data_list
    @category = Category.find_by(title: params[:title])
  end

  def import
    @klass = Klass.find_by(name: "Inventory")
    @import_data_csvs = current_user.import_data_csvs.where(klass_id: @klass.id).order(created_at: :desc)
  end

  def import_map
    @document = Document.create(attachment: params[:import], resourcable: current_user)
    @headers = CSV.open(params[:import].path, &:readline)
    @klass = Klass.find_by(name: "Inventory")
    @fields = Field.where(klass: @klass).where.not(group_id: nil)
    @data =  CSV.read(params[:import].path, :headers=>true)
    @sample_data = @data[0]
    @errors = false
  end

  def import_file
    @document = Document.find(params[:document_id])
    @errors = Inventory.import(@document.attachment)
    if @errors.present?
      flash[:danger] = @errors.join(",")
    else
      flash[:success] = "CSV imported successfully"
    end
    redirect_to inventories_path
  end

  def logs
    @inventory = Inventory.find(params[:id])
  end

  private
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    def set_klass
      @klass = Klass.find_by(name: 'Inventory')
      @data = {}
      fields = Field.where(klass: @klass, have_custom_value: true)
      fields.each do |field|
        @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
      end
    end

    def inventory_params

      @klass = Klass.find_by(name: "Inventory")
      @groups = @klass.groups.where.not(name: "default_group")
      @fields = []
      @groups.each do |group|
        @fields << group.fields.pluck(:name)
      end

      inventory_params_object = params.require(:inventory)
      category = Category.find_or_create_by(title: inventory_params_object[:category]) if inventory_params_object[:category].present?
      brand = Brand.find_or_create_by(name: inventory_params_object[:brand]) if inventory_params_object[:brand].present?
      merchant = Merchant.find_or_create_by(name: inventory_params_object[:merchant]) if inventory_params_object[:merchant].present?
      unit = Unit.find_or_create_by(name: inventory_params_object[:unit]) if inventory_params_object[:unit].present?

      inventory_params_object[:unit_id] = unit.id if unit
      inventory_params_object[:merchant_id] = merchant.id if merchant
      inventory_params_object[:brand_id] = brand.id if brand
      if category
        inventory_params_object[:category_id] = category.id
        inventory_params_object[:subcategory_id] = category.subcategories.find_or_create_by(title: inventory_params_object[:subcategory]).id if category.present? && inventory_params_object[:subcategory]
      end
      inventory_params_object.permit(Inventory::PERMITTED_PARAMS, @fields.flatten, multi_select_params_permit(@klass))
    end
end
