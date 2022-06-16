class SubcategoriesController < ApplicationController
  before_action :authenticate_user!

  def new
    subcategory
  end

  def edit
    subcategory
  end

  def create
    if subcategory.update(subcategory_params)
      flash[:success] = 'Subcategory Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Subcategory!'
    end
    redirect_to categories_path
  end

  def update
    if subcategory.update(subcategory_params)
      flash[:success] = 'Subcategory Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Subcategory!'
    end
    redirect_to categories_path
  end

  def destroy
    if subcategory.destroy
      flash[:success] = 'Subcategory Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Subcategory!'
    end
    redirect_to categories_path
  end

  private

  def subcategory
    @subcategory ||= if params[:id].present?
                       Subcategory.find(params[:id])
                     else
                       Subcategory.new
                     end
  end

  def subcategory_params
    params.require(:subcategory).permit(:title, :category_id)
  end
end
