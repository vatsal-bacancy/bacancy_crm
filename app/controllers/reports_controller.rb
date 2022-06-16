class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def deployment
  end

  def ipos_login_details
    respond_to do |format|
      format.html
      format.json do
        self.formats = [] # Without this we are not able to render `html` partials in json response
        render json: Reports::IPosLoginDetailsDatatable.new(params, view: view_context)
      end
    end
  end
end
