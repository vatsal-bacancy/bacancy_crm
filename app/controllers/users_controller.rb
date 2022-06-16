class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_klass
  before_action :check_user, only: [:create]

  def check_user
    @user = User.where(email: params["user"][:email]).first
  end

  def index
    @klass = Klass.find_by(name: "User")
    can_perform?(@klass, @action_read)
    # if current_user.has_role?(:super_admin)
    @users = User.all
    # else
      # @users = User.all
      # @users = current_user.all_user_of_related_company
    # end
  end

  def new
    @user = User.new
    @groups = Group.includes(:fields).where(klass: @klass)
    @data = {role_ids: Role.all.pluck(:name, :id), client_ids: Client.all.pluck(:company_name, :id)}
  end

  def show
  end

  def edit
    @user = User.find(params[:id])
    @groups = Group.includes(:fields).where(klass: @klass)
    @data = {role_ids: Role.all.pluck(:name, :id), client_ids: Client.all.pluck(:company_name, :id)}
    if params[:company_id].present?
      @company = Company.find(params[:company_id])
    end
  end

  def create
    @user = User.new(users_params)
    if @user.save
      flash[:success] = "User successfully added"
      @user.send_account_setup_instructions(current_user)
      @users = User.all
    else
      flash[:danger] = @user.errors.full_messages.join(",")
    end
    redirect_to users_path
  end

  def update
    @user = User.find(params[:id])
    if @user.update(users_params)
      flash[:success] = "User successfully updated "
    else
      flash[:danger] = @user.errors.full_messages.join(",")
    end

    if params[:edit_company].present?
      @company = Company.find(params[:company_id])
      if @company.update_attributes(name: params[:name],email: params[:email], domain_url: params[:domain_url],website_url: params[:website_url], work_phone: params[:work_phone],street_address: params[:street_address], city: params[:city], state: params[:state], zip_code: params[:zip_code] )
         @user.errors.any? ? (flash[:danger] ="user #{@user.errors.full_messages.join(",")}") : (flash[:success] ="User and Company successfully updated")
      else
        @user.errors.any? ? (flash[:danger] ="user #{@user.errors.full_messages.join(",")} and company #{@company.errors.full_messages.join(",")}") : (flash[:danger] = @company.errors.full_messages.join(","))
        #flash[:danger] = @company.errors.full_messages.join(",")
      end
    end
    @users = User.all
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy_and_migrate_date_to(@company.user)
    @users = User.all
  end

  def remove_image
    #delete image
    @user = User.find(params[:user_id])
    @user.remove_profile_picture!
    if @user.save
    #@user.profile_picture = nil
      flash[:success] = "Successfully remove"
    else
      flash[:danger] = "Enable to remove"
    end
    #redirect_to user_path(@user)
  end

  def signature
    @user = User.find(params[:user_id])
  end

  def update_signature
    current_user.update(signature: params[:user][:signature])
  end

  def new_image
    #get user
    @user_company =  params[:company_id].present? ? Company.find(params[:company_id]) : nil
    @user = User.find(params[:user_id])
    @field = params[:image]
  end


  def upload_image
    @company = params[:company_id].present? ? Company.find(params[:company_id]) : nil 
    @field = params[:field]
    @user = User.find(params[:user_id])
    image_data = Base64.decode64(params[:image]['data:image/png;base64,'.length .. -1])
    filename =  params[:company_id].present? ? "#{@field}_#{@company.id}" :"#{@field}_#{@user.id}"
    tmpfile = File.open(Rails.root.join("tmp/#{filename}.jpg"), 'wb')
    tmpfile.write(image_data)
    if @company.present? 
      @company.update_attributes( @field => tmpfile ) ? flash[:success] = "Logo has been uploaded" :flash[:danger] = "Unable to upload logo"
    else
      @user.update_attributes( @field => tmpfile ) ? flash[:success] = "Picture has been uploaded" :flash[:danger] = "Unable to upload picture"
    end
    #redirect_to user_path(@user)
  end

  def resend_invitation
    @user = User.find(params[:user_id])
    @user.active? ?  @user.send_login_instructions(current_user) : @user.send_account_setup_instructions(current_user)
    @users = User.all
  end

  private

  def users_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role_ids, :profile_picture, :phone_no, :signature)
  end

  def set_klass
    @klass = Klass.find_by(name: 'User')
  end
end
