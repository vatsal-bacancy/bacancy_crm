class Api::V1::EmployeesController < Api::V1::BaseController
  skip_before_action :verify_authenticity_token

  def index
    find_user(params[:country_code], params[:phone_number])
    if @user.present?
      client = Client.find_by_id params[:client_id]
      if client.present?
        employees = client.employees.select(:id, :full_name, :country_code, :phone_number, :client_id).as_json
        employees_hash = { employees: employees }
        api_success(200, 'All Employees have been fetched successfully.', employees_hash)
      else
        api_error(400, 'Client not found!')
      end
    else
      api_error(400, 'User not found!')
    end
  end

  def create
    find_user(permitted_params[:country_code], permitted_params[:phone_number])
    if @user.present?
      employees_with_error = []
      saved_employees = []
      employees = Employee.create(permitted_params[:employees])
      employees.each do |employee|
        if employee.invalid?
          employee_error = { employee: { full_name: employee.full_name, country_code: employee.country_code, phone_number: employee.phone_number, client_id: employee.client_id },
                             errors: employee.errors.full_messages }
          employees_with_error << employee_error
        else
          saved_employees << { id: employee.id, full_name: employee.full_name, country_code: employee.country_code, phone_number: employee.phone_number, client_id: employee.client_id }
          begin
            employee.send_feedback_link
          rescue => e
          end
        end
      end
      employees_hash = { saved_employees: saved_employees, unsaved_employees: employees_with_error }
      api_success(200, 'Employees have been saved.', employees_hash)
    else
      api_error(400, 'User not found!')
    end
  end

  # Create method issue
  def employee_create
    find_user(permitted_params[:country_code], permitted_params[:phone_number])
    if @user.present?
      employees_with_error = []
      saved_employees = []
      employees = Employee.create(permitted_params[:employees])
      employees.each do |employee|
        if employee.invalid?
          employee_error = { employee: { full_name: employee.full_name, country_code: employee.country_code, phone_number: employee.phone_number, client_id: employee.client_id },
                             errors: employee.errors.full_messages }
          employees_with_error << employee_error
        else
          saved_employees << { id: employee.id, full_name: employee.full_name, country_code: employee.country_code, phone_number: employee.phone_number, client_id: employee.client_id }
        end
      end
      employees_hash = { saved_employees: saved_employees, unsaved_employees: employees_with_error }
      api_success(200, 'Employees have been saved.', employees_hash)
    else
      api_error(400, 'User not found!')
    end
  end

  def destroy
    find_user(permitted_params[:country_code], permitted_params[:phone_number])
    if @user.present?
      client = Client.find_by_id permitted_params[:client_id]
      if client.present?
        employee = Employee.find_by_id permitted_params[:employee_id]
        employee&.destroy
        api_success(200, 'Employee has been deleted successfully.', {})
      else
        api_error(400, 'Client not found!')
      end
    end
  end

  private

  def find_user(country_code, phone_number)
    user_phone_number = ''
    if country_code.to_i != 1
      user_phone_number = country_code.gsub(' ', '+') + phone_number
    else
      user_phone_number = phone_number
    end
    @user ||= User.find_by_phone_no(user_phone_number)
  end

  def permitted_params
    params.require(:data).permit(:country_code, :phone_number, :client_id, employees: [:phone_number, :country_code, :full_name, :client_id])
  end
end
