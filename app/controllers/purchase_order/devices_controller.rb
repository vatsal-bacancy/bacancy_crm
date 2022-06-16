class PurchaseOrder::DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :update_payment_options, only: [:create, :update]

  def index
    @devices = PurchaseOrder::Device.all.sort_by_order_with_category
  end

  def new
    device
    device.device_products.build
  end

  def edit
    device
  end

  def create
    if device.update(device_params)
      flash[:success] = 'Device Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Device!'
    end
    redirect_to purchase_order_devices_path
  end

  def update
    if device.update(device_params)
      flash[:success] = 'Device Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Device!'
    end
    redirect_to purchase_order_devices_path
  end

  def destroy
    if device.destroy
      flash[:success] = 'Device Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Device!'
    end
    redirect_to purchase_order_devices_path
  end

  private

  def device
    @device ||= if params[:id].present?
                  PurchaseOrder::Device.find(params[:id])
                else
                  PurchaseOrder::Device.new
                end
  end

  # TODO: use nested attributes for code optimization
  def update_payment_options
    device.device_payment_options.destroy_all
    return if params[:payment_options].blank?
    params[:payment_options].reject_blank.map do |p|
      device.device_payment_options.build(payment_option_id: p)
    end
  end

  def device_params
    params.require(:purchase_order_device).permit(:name, :description, :category, :order, device_products_attributes: [:id, :product_id, :_destroy])
  end
end
