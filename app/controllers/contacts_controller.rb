class ContactsController < ApplicationController
  before_action :authenticate_user!, :set_klass

  def index
    # @user = UserClientDetail.find_by(user_id: @current_user.id)
    # @client = Client.find(@user.client_id)
    # @contacts = @client.contacts
  end

  def check_email
    @contact = Contact.find_by(email: params[:email])
    render json: @contact.present?
  end

  def new
    @contact = Contact.new
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def create
    @contact = Contact.new(contacts_params)
    if @contact.save
      params[:contactable_id] = params[:contactable_id].present? ? params[:contactable_id] : params[:contact][:contactable_id]
      @contact.lead_client_contact = LeadClientContact.create(contact_id: @contact.id, contactable_type: params[:contactable_type], contactable_id: params[:contactable_id])
      @contactable = @contact.lead_client_contact.contactable
      if @contact.portal_invitation
        @contact.send_account_setup_instructions(current_user)
      end
      flash[:success] = "Contact successfully added"
    else
      flash[:danger] = @contact.errors.full_messages.join(", ")
      # render :new
    end
  end

  def update
    @contact = Contact.find(params[:id])
    @contactable = @contact.lead_client_contact.contactable
    if @contact.update(contacts_params)
      flash[:success] = "Contact successfully updated"
      if @contact.portal_invitation
        if @contact.active?
          @contact.send_login_instructions(current_user)
        else
          @contact.send_account_setup_instructions(current_user)
        end
      end
    else
      flash[:danger] = @contact.errors.full_messages.join(",")
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contactable = @contact.lead_client_contact.contactable
    @contact.destroy
    flash[:success] = "Contact successfully deleted"
  end

  def resend_invitation
    @contact = Contact.find(params[:contact_id])
    @contact.update(portal_invitation: true)
    @contact.active? ? @contact.send_login_instructions(current_user) : @contact.send_account_setup_instructions(current_user)
  end


  def lead_contacts
    @klass = Klass.find_by(name: 'Contact')
    can_perform?(@klass, @action_read)
    @contacts = Contact.joins(:lead_client_contact).where(lead_client_contacts: {contactable_type: 'Lead'})
  end

  def client_contacts
    @klass = Klass.find_by(name: 'Contact')
    can_perform?(@klass, @action_read)
    @contacts = Contact.joins(:lead_client_contact).where(lead_client_contacts: {contactable_type: 'Client'})
  end

  def vendor_contacts
    @klass = Vendor.klass
    @contacts = Contact.joins(:lead_client_contact).where(lead_client_contacts: {contactable_type: 'Vendor'})
  end

  def destroy_all
    @klass = Klass.find_by(name: 'Contact')
    can_perform?(@klass, @action_read)
    @contacts = Contact.where(id: params[:ids])
    @lead_client_contact = LeadClientContact.where(contact_id: params[:ids])
    @object = @lead_client_contact.first.contactable_type
    @lead_client_contact.delete_all
    @contacts.delete_all
    if @object == 'Client'
      @contacts = Contact.joins("INNER JOIN lead_client_contacts on lead_client_contacts.contact_id = contacts.id").where("lead_client_contacts.contactable_type= 'Client'")
    elsif @object == 'Lead'
      @contacts = Contact.joins("INNER JOIN lead_client_contacts on lead_client_contacts.contact_id = contacts.id").where("lead_client_contacts.contactable_type= 'Lead'")
    end
  end

  private

  def contacts_params
    params.require(:contact).permit(:first_name, :last_name, :email, :phone_no, :portal_invitation)
  end

  def lead_client_contact_params
    params.require(:contact).permit(:first_name, :last_name, :email, :phone_no, :portal_invitation)
  end

  def set_klass
    @klass = Klass.find_by(name: 'Contact')
  end
end
