class Users::TimeSheetLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user!, only: [:create, :update, :destroy]

  def all_users
    @users_data = OpenStruct.new
    @users_data.start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.days_ago(6)
    @users_data.end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
    @users_data.records = User::TimeSheetLog.with_week_day_group(User.all_active_users, @users_data.start_date..@users_data.end_date)
  end

  def index
    @time_sheet_log_data = OpenStruct.new
    @time_sheet_log_data.user = user
    @time_sheet_log_data.start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.days_ago(6)
    @time_sheet_log_data.end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
    @time_sheet_log_data.records = user.time_sheet_logs.with_date_group(@time_sheet_log_data.start_date..@time_sheet_log_data.end_date)
  end

  def new
    time_sheet_log.assign_attributes(base_date: params[:base_date])
  end

  def edit
    time_sheet_log
  end

  def create
    if time_sheet_log.update(time_sheet_log_params)
      flash[:success] = 'Timesheet Log Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Adding Updating Timesheet Log!'
    end
    redirect_to edit_user_time_sheet_log_path(time_sheet_log.user, time_sheet_log)
  end

  def update
    if time_sheet_log.update(time_sheet_log_params)
      flash[:success] = 'Timesheet Log Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Adding Updating Timesheet Log!'
    end
    redirect_to edit_user_time_sheet_log_path(time_sheet_log.user, time_sheet_log)
  end

  def destroy
    if time_sheet_log.destroy
      flash[:success] = 'Timesheet Log Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting Timesheet Log!'
    end
    redirect_to user_time_sheet_logs_path(time_sheet_log.user)
  end

  def clock_in_out_toggle
    if current_user.clocked_in?
      User::TimeSheetLog.create_clock_out_log(current_user)
    else
      User::TimeSheetLog.create_clock_in_log(current_user)
    end
    redirect_to request.referer
  end

  def settings
    setting
  end

  def update_settings
    if setting.update(setting_params)
      flash[:success] = 'Settings Successfully Saved!'
    else
      flash[:danger] = setting.errors.full_messages.to_sentence
    end
    redirect_to time_sheet_logs_settings_users_path
  end

  private

  def time_sheet_log
    @time_sheet_log ||= if params[:id].present?
                          User::TimeSheetLog.find(params[:id])
                        else
                          user.time_sheet_logs.build
                        end
  end

  def user
    @user ||= User.find(params[:user_id])
  end

  def time_sheet_log_params
    params.require(:user_time_sheet_log).permit(:base_date, :clock_in_datetime, :clock_out_datetime, break_logs_attributes: [:id, :_destroy, :start_datetime, :end_datetime])
  end

  def setting
    @setting ||= User::TimeSheetLog::EmailSetting.get_record
  end

  def setting_params
    params.require(:user_time_sheet_log_email_setting).permit(:days_range, :recurrence_schedule, recipients: [])
  end

  def authorize_user!
    unless current_user.is_super_admin?
      flash[:danger] = 'You Are Not Authorized!'
      redirect_to time_sheet_logs_all_users_users_path
    end
  end
end
