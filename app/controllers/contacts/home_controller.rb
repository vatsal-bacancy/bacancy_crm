include Geokit::Geocoders

class Contacts::HomeController < ApplicationController
  layout 'contacts'
  before_action :authenticate_contact!
  include AuthHelper

  def dashboard
    @project_unread_count = current_contact.unreads.where(unreadable_type: 'Project').count
    @project_count = current_contact.projects.count
    @invoice_unread_count = current_contact.unreads.where(unreadable_type: 'Invoice').count
    @invoice_count = current_contact.lead_client_contact.contactable.invoices.count
    @ticket_unread_count = current_contact.unreads.where(unreadable_type: 'Ticket').count
    @ticket_count = current_contact.associated_tickets.count
  end

  def view_map
    # render layout: false
    coords = MultiGeocoder.geocode(params[:address])
    @lat = coords.lat
    @long = coords.lng

  end

  def page1

  end

  def project_communication_dashborad1
  end
end
