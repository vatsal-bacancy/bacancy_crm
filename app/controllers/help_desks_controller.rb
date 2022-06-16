class HelpDesksController < ApplicationController
  before_action :authenticate_user!

  def index
    help_desks = HelpDesk.select(:id, :category, :title)
    if params[:search].present?
      help_desks = help_desks.where('category ILIKE :search OR title ILIKE :search', search: "%#{params[:search]}%")
    end
    @help_desks_with_category = help_desks.all_with_category
  end

  def new
    help_desk
  end

  def edit
    help_desk
  end

  def show
    help_desk
  end

  def create
    if help_desk.update(help_desk_params)
      flash[:success] = 'Help Desk Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Help Desk!'
    end
    redirect_to help_desks_path
  end

  def update
    if help_desk.update(help_desk_params)
      flash[:success] = 'Help Desk Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Help Desk!'
    end
    redirect_to help_desks_path
  end

  def destroy
    if help_desk.destroy
      flash[:success] = 'Help Desk Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Help Desk!'
    end
    redirect_to help_desks_path
  end

  private

  def help_desk
    @help_desk = if params[:id].present?
                   HelpDesk.find(params[:id])
                 else
                   HelpDesk.new
                 end
  end

  def help_desk_params
    params.require(:help_desk).permit(:category, :title, :description)
  end
end
