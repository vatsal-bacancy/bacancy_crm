class Contacts::ContactsController < ApplicationController
  before_action :authenticate_contact!

  layout 'contacts'

  def show
    @contact = Contact.find(params[:id])
    @client = @contact.lead_client_contact.contactable
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @contact = Contact.find(params[:id])
    if @contact.update(contact_params)
      flash[:success] = "Successfully contact updated"
    else
      flash[:danger] = @contact.errors.full_messages.join(",")
    end
  end

  def company_edit
    @contact = Contact.find(params[:contact_id])
    @company = @contact.lead_client_contact.contactable
  end

  def company_update
    #in contact profile update using popup
    @contact = Contact.find(params[:contact_id])
    if @contact.update(contact_params)
      flash[:success] = "Successfully contact updated"
    else
      flash[:danger] = @contact.errors.full_messages.join(",")
    end

    if params[:company_id].present?
      @client = Client.find(params[:company_id])
      if @client.update(company_name: params[:company_name],company_email: params[:company_email],phone_no: params[:phone_no],company_url: params[:company_url],street_address: params[:street_address],state: params[:state],city: params[:city],zip_code: params[:zip_code])
        @contact.errors.any? ? (flash[:danger] ="Contact #{@contact.errors.full_messages.join(",")}") : (flash[:success] ="Contact and Company successfully updated")
        #flash[:success] = "Successfully company updated"
      else
        @contact.errors.any? ? (flash[:danger] ="Contact #{@contact.errors.full_messages.join(",")} and company #{@client.errors.full_messages.join(",")}") : (flash[:danger] = @client.errors.full_messages.join(","))
        #flash[:danger] = @client.errors.full_messages.join(",")
      end
    else
      @client = @contact.lead_client_contact.contactable
    end
  end

  def client_update
    @client = Client.find(params[:id])
    if @client.update(company_params)
      flash[:success] = 'Company successfully updated'
    else
      flash[:danger] = @client.errors.full_messages.join(",")
    end
  end

  def remove_image
    #delete image
    @contact = Contact.find(params[:contact_id])
    @contact.remove_profile_picture!
    if @contact.save
      flash[:success] = "Successfully save"
    else
      flash[:danger] = "Enable to remove"
    end
    #redirect_to contacts_contact_path(@contact)
  end

  def upload_image
    #update profile_picture
    @contact = Contact.find(params[:contact_id])

    image_data = Base64.decode64(params[:image]['data:image/png;base64,'.length .. -1])
    filename = @contact.id
    tmpfile = File.open(Rails.root.join("tmp/#{filename}.jpg"), 'wb')
    tmpfile.write(image_data)

    if @contact.update_attributes(profile_picture: tmpfile)
      flash[:success] = "Picture has been uploaded"
    else
      flash[:danger] = "Unable to upload picture"
    end
    flash[:success] = "Successfully save"
    #redirect_to contacts_contact_path(@contact)
  end

  def new_image
    #pop call for image
    @contact = Contact.find(params[:contact_id])
  end

  def phone_update
    @contact = Contact.find(params[:contact_id])
    @contact.update_attributes(phone_no: params[:phone_no])
  end

  private
  def contact_params
    params.require(:contact).permit(:first_name,:last_name,:phone_no,:email)
  end

  def company_params
    params.require(:client).permit(:company_name,:company_email,:phone_no,:company_url,:street_address,:state,:city,:zip_code)
  end
  
end
