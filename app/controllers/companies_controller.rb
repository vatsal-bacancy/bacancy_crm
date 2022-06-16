class CompaniesController < ApplicationController
  
  def update
    @company = Company.find(params[:id])
    @user = User.find(params[:company][:user_id])
    if @company.update(company_params)
      flash[:success] = "Company successfully updated "
    else
      flash[:danger] = @company.errors.full_messages.join(",")
    end
    respond_to do |format|
      format.html {redirect_to user_path(current_user)}
      format.js
    end
    #render jeson: { comapny_name: @comapny.name }
  end

  def logo_image
    @company = Company.find(params[:company_id])
    @field = params[:image].to_sym
  end

  def remove_logo
    @company = Company.find(params[:company_id])
    @user = User.find(params[:user_id])
    params[:image] == "big_logo" ? @company.remove_big_logo! : (params[:image] == "small_logo" ? @company.remove_small_logo! : @company.remove_fevicon_logo!)
    if @company.save
      flash[:success] = "Success fully remove Logo"
    else
      flash[:danger] = "Unable to remove logo"
    end
  end

  private
  def company_params
    params.require(:company).permit(:name,:email,:website_url,:work_phone,:street_address,:city,:state,:zip_code,:description,:big_logo,:small_logo,:fevicon_logo)
  end
end
