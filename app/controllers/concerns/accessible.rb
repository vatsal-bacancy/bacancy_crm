# ../controllers/concerns/accessible.rb
module Accessible
  extend ActiveSupport::Concern
  included do
    before_action :check_user
  end

  protected
  def check_user
    if current_contact
      flash.clear
      # if you have rails_admin. You can redirect anywhere really
      redirect_to(contacts_dashboard_path) && return
    elsif current_user
      flash.clear
      # Commenting out `redirect_to`, because we wants `Users::SessionsController#create` to be called.
      # redirect_to(root_path) && return
    end
  end
end
