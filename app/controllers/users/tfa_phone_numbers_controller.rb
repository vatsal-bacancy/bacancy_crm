class Users::TfaPhoneNumbersController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :clear_xhr_flash

  def index
    @phone_numbers = User::TfaPhoneNumber.all
  end

  def new
    phone_number
  end

  def create
    if phone_number.update(phone_number_params)
      flash[:success] = 'Phone Number Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Phone Number!'
    end
    redirect_to users_tfa_phone_numbers_path
  end

  def destroy
    if phone_number.destroy
      flash[:success] = 'Phone Number Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Phone Number!'
    end
    redirect_to users_tfa_phone_numbers_path
  end

  private

  def phone_number
    @phone_number ||= if params[:id].present?
                        User::TfaPhoneNumber.find(params[:id])
                      else
                        User::TfaPhoneNumber.new
                      end
  end

  def phone_number_params
    params.require(:user_tfa_phone_number).permit(:number)
  end
end
