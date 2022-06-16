include Geokit::Geocoders

class HomeController < ApplicationController
  before_action :authenticate_user!
  include AuthHelper

  def dashboard
    if current_user.role.try(:name) == 'Sales'
      merchant_ids = current_user.clients.pluck(:nab_merchant_id_mid_).reject(&:blank?)
      begin
        resp = Faraday.post("http://#{amount_collection_host}/api/v1/locations_amount_collections/amount_collection") do |req|
          req.headers['accept'] = 'application/json'
          req.body = { 'locations_amount_collection': { 'merchant_ids': merchant_ids } }
        end
        response_body = JSON.parse(resp.body)
        @chart_data = response_body['data']['date_wise_amount_collection']&.sort
        @last_month_amount_collection = response_body['data']['last_month_amount_collection']
        @last_30_days_amount_collection = response_body['data']['last_30_days_amount_collection']
        @amount_by_merchant_id = response_body['data']['location_merchant_amount']
      rescue
        @error = "Parent Host didn't respond properly."
      end
      @last_month = Date::MONTHNAMES[(Date.today - 1.month).month]
      @start_date = (Date.today - 31).strftime
      @end_date = (Date.today - 1).strftime
      @today = Date.today.strftime
      @clients = current_user.clients
      @deployments = current_user.meetings.last_30_days
      @tickets = current_user.owned_tickets.last_30_days
      # @deployments = current_user.meetings.where('start_time > ?', 31.days.ago)
    else 
      @project_unread_count = current_user.unreads.where(unreadable_type: 'Project').count
      @project_count = current_user.has_role?(:super_admin) ? Project.count : current_user.projects.count
      # TODO: implement invoice_unread_count
      @invoice_count = Invoice.count
      @owned_tickets_count = current_user.owned_tickets.count
      @associated_tickets_count = current_user.associated_tickets.count
      @lead_contact =  LeadClientContact.where(contactable_type: "Lead").count
      @lead_count = Lead.count
      @client_contact = LeadClientContact.where(contactable_type: "Client").count
      @client_count = Client.count
      @task_count = Task.count
      @inventory_count = InventoryGroup.count
      @help_desk_count = HelpDesk.count
      @contract_count = Contract::Contract.count
    end
  end

  def view_map
    # render layout: false
    coords = MultiGeocoder.geocode(params[:address])
    @lat = coords.lat
    @long = coords.lng
  end

  def page1
  end

  def privacy
  end

  def project_communication_dashborad1
  end

  private

  def amount_collection_host
    Rails.env.development? ? 'goipos.net' : 'goipos.net'
  end
end
