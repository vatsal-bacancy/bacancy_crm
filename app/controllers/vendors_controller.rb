class VendorsController < ApplicationController
  before_action :authenticate_user!
  before_action :fields, :fields_picklist_data

  def index
    respond_to do |format|
      format.html
      format.js
      format.json do
        render json: VendorDatatable.new(params, vendors: Vendor.all, fields: fields, fields_picklist_data: fields_picklist_data)
      end
    end
  end

  def new
    vendor
  end

  def edit
    vendor
  end

  def show
    vendor
  end

  def edit_summary
    vendor
    @group = Group.find(params[:group_id])
  end

  def create
    if vendor.update(vendor_params.merge(assigned_to: current_user))
      flash.now[:success] = 'Vendor Successfully Added!'
    else
      flash.now[:danger] = 'Error Occurred While Adding A Vendor!'
    end
  end

  def update
    if vendor.update(vendor_params)
      flash.now[:success] = 'Vendor Successfully Updated!'
    else
      flash.now[:danger] = 'Error Occurred While Updating A Vendor!'
    end
  end

  def destroy
    if vendor.destroy
      flash.now[:success] = 'Vendor Successfully Deleted!'
    else
      flash.now[:danger] = 'Error Occurred While Deleting A Vendor!'
    end
  end

  def destroy_all
    if Vendor.where(id: params[:ids]).destroy_all
      flash.now[:success] = 'Selected Vendors Successfully Deleted!'
    else
      flash.now[:danger] = 'Something Went Wrong While Deleting Selected Vendors!'
    end
  end

  private

  def klass
    @klass ||= Vendor.klass
  end

  def fields
    @fields ||= current_user.fields_for_table_with_order(klass: klass)
  end

  def fields_picklist_data
    @fields_picklist_data ||= begin
                                klass.fields.field_picklist_valuable.includes(:field_picklist_values).inject({}.with_indifferent_access) do |hash, field|
                                  hash[field.name] = field.field_picklist_values.pluck(:value)
                                  hash
                                end
                              end
  end

  def vendor
    @vendor ||= if params[:id].present?
                  Vendor.find(params[:id])
                else
                  Vendor.new
                end
  end

  def vendor_params
    params.require(:vendor).permit(klass.fields.pluck(:name), multi_select_params_permit(klass), contacts_attributes: {})
  end
end
