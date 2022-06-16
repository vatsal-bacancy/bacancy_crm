class Public::ClientsController < ApplicationController
  layout 'public'

  def edit
    client
    client_menu_approved_field
  end

  def update
    if client.update(client_params)
      flash[:success] = 'Your Response Has Been Submitted!'
    else
      flash[:danger] = 'Something Went Wrong While Submitting Your Response!'
    end
    redirect_to status_public_client_path
  end

  def status
  end

  private

  def client_params
    params[:client]['menu_approval_ip'] = request.remote_ip
    params[:client]['menu_approval_date_time'] = DateTime.current
    params[:client]['menu_approval_address'] = request.location.address
    params.require(:client).permit(client_fields.pluck(:name))
  end

  def client_fields
    @client_fields ||= Client.klass.fields.where(name: ['client_menu_approved', 'menu_approval_ip', 'menu_approval_date_time', 'menu_approval_address'])
  end

  def client_menu_approved_field
    @client_menu_approved_field ||= client_fields.detect { |field| field.name == 'client_menu_approved' }
  end

  def client
    @client ||= Client.find_by_encrypted_id(params[:id])
  end
end
