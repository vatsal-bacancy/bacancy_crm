class FeedbacksController < ApplicationController
  skip_before_action :verify_authenticity_token
  layout 'feedback'

  def create
    if employee(feedback_params[:employee_country_code], feedback_params[:employee_phone_number]).present?
      store_feedback_response
      if @error
        flash[:alert] = 'Something went wrong.'
      else
        flash[:notice] = 'Your feedback has been saved successfully.'
      end
    else
      @error = true
      flash[:alert] = 'Something went wrong.'
    end
  end

  def send_otp
    if employee(employee_params[:country_code], employee_params[:phone_number]).present?
      @employee.send_feedback_otp
      flash[:notice] = 'OTP has been sent to your phone number.'
    else
      @error = true
      flash[:alert] = 'The Employee is not registered with us.'
    end
  end

  def verify_otp
    if employee(otp_params[:otp_country_code], otp_params[:otp_phone_number]).present?
      if @employee.verify_feedback_otp(otp_params[:otp])
        @questions = FeedbackQuestion.all
        flash[:notice] = 'OTP has been verified successfully.'
      else
        @error = true
        flash[:alert] = 'OTP is wrong.'
      end
    else
      @error = true
      flash[:alert] = 'Something went wrong.'
    end
  end

  private

  def store_feedback_response
    retraining = false
    ActiveRecord::Base.transaction do
      begin
        feedback_params[:questions].as_json.each do |_k, feedback_answer|
          efa = EmployeeFeedbackAnswer.find_or_create_by(feedback_answer.slice('employee_id', 'feedback_question_id'))
          retraining_param = feedback_answer.slice('retraining')
          efa.update(retraining_param)
          retraining = true if retraining_param['retraining'] == 'true'
        end
        @employee.update(retraining: retraining)
      rescue => e
        @error = true
      end
    end
  end

  def employee(country_code, phone_number)
    @employee ||= Employee.find_by_country_code_and_phone_number(country_code, phone_number)
  end

  def employee_params
    params.permit(:country_code, :phone_number)
  end

  def otp_params
    params.permit(:otp, :otp_country_code, :otp_phone_number)
  end

  def feedback_params
    params.permit(:employee_country_code, :employee_phone_number, questions: {})
  end
end