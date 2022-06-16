class StockAdjustmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock_adjustment, only: %i[edit destroy update]

  def edit
  end

  def new
    @stock_adjustment = StockAdjustment.new(inventory_id: params[:inventory_id])
  end

  def create
    @stock_adjustment = StockAdjustment.new(stock_adjustment_params)
    if @stock_adjustment.save
      flash[:success] = 'Stock adjusted successfully.'
    else
      flash[:danger] = 'Stock can not adjust.'
    end
  end

  def update
  end

  def destroy
    @inventory = @stock_adjustment.inventory
    if @stock_adjustment.destroy
      flash[:success] = 'Stock adjustment deleted successfully.'
    else
      flash[:danger] = 'Stock adjustment cannot delete.'
    end
  end

  private

  def stock_adjustment_params
    params[:stock_adjustment][:adjustment_type] = params[:stock_adjustment][:adjustment_type].to_i
    params.require(:stock_adjustment).permit(StockAdjustment::PERMITTED_PARAMS)
  end

  def set_stock_adjustment
    @stock_adjustment = StockAdjustment.find(params[:id])
  end
end
