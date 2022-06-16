class CategoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.includes(:subcategories).all
  end

  def new
    category
  end

  def edit
    category
  end

  def create
    if category.update(category_params)
      flash[:success] = 'Category Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Category!'
    end
    redirect_to categories_path
  end

  def update
    if category.update(category_params)
      flash[:success] = 'Category Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Category!'
    end
    redirect_to categories_path
  end

  def destroy
    if category.destroy
      flash[:success] = 'Category Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Category!'
    end
    redirect_to categories_path
  end

  private

  def category
    @category ||= if params[:id].present?
                    Category.find(params[:id])
                  else
                    Category.new
                  end
  end

  def category_params
    params.require(:category).permit(:title)
  end
end
