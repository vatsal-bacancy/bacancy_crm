class PurchaseOrder::ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = PurchaseOrder::Product.all
  end

  def new
    product
  end

  def edit
    product
  end

  def create
    if product.update(product_params)
      flash[:success] = 'Product Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Product!'
    end
    redirect_to purchase_order_products_path
  end

  def update
    if product.update(product_params)
      flash[:success] = 'Product Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Product!'
    end
    redirect_to purchase_order_products_path
  end

  def destroy
    if product.destroy
      flash[:success] = 'Product Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Product!'
    end
    redirect_to purchase_order_products_path
  end

  private

  def product
    @product ||= if params[:id].present?
                   PurchaseOrder::Product.find(params[:id])
                 else
                   PurchaseOrder::Product.new
                 end
  end

  def product_params
    params.require(:purchase_order_product).permit(:name, :price, :available, :product_type)
  end
end
