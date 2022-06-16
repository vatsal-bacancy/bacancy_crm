# As per http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/
module Clients
  class EmployeesController < ApplicationController
    before_action :authenticate_user!
    before_action :get_employee, only: [:new, :edit, :update, :destroy, :feedback]
    before_action :get_client, only: [:index, :new, :edit, :update, :destroy]

    def create
      @employee = Employee.new(client_employee_params)
      if @employee.save
        get_client
        flash[:success] = 'Employee Successfully Added!'
      else
        flash[:danger] = @employee.errors.full_messages.join(',')
      end
    end

    def update
      if @employee.update(client_employee_params)
        flash[:success] = 'Employee Successfully Updated!'
      else
        flash[:danger] = @employee.errors.full_messages.join(',')
      end
    end

    def destroy
      if @employee.destroy
        flash[:success] = 'Employee Successfully Deleted!'
      else
        flash[:danger] = @employee.errors.full_messages.join(',')
      end
    end

    def feedback
      @questions_answers = @employee.employee_feedback_answers.where(retraining: true)
    end

    private

    def get_employee
      @employee ||= if params[:id]
                      Employee.find(params[:id])
                    else
                      get_client.employees.new
                    end
    end

    def get_client
      @client ||= Client.find(params[:client_id])
    end

    def client_employee_params
      params[:employee].permit(:client_id, :full_name, :country_code, :phone_number)
    end
  end
end
