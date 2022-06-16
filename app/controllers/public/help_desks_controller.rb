class Public::HelpDesksController < ApplicationController
  layout 'public'

  def index
    help_desks = HelpDesk.select(:id, :category, :title)
    if params[:search].present?
      help_desks = help_desks.where('category ILIKE :search OR title ILIKE :search', search: "%#{params[:search]}%")
    end
    @help_desks_with_category = help_desks.all_with_category
  end

  def show
    @help_desk = HelpDesk.find(params[:id])
  end
end
