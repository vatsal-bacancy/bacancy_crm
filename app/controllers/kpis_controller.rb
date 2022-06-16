class KpisController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def sales
  end

  def marketing
  end

  def sales_lead_contracts_pipeline
    @contracts = Contract::Contract
                   .includes(:user)
                   .of('Lead')
                   .where('created_at >= ? AND created_at <= ?', params[:start_date], params[:end_date])
                   .order(created_at: :desc)
    @contracts_with_users_group = @contracts.group_by { |contract| contract.user }
  end

  # Note: This depends on dynamic fields so if deleted then it could break the application
  # We need to improve this action
  def sales_lead_status
    sales_assign_to_field_name = 'sales__assign__to'
    sales_lead_status_field_name = 'sales__lead__status'
    @leads = Lead
               .where.not(sales_assign_to_field_name => nil, sales_lead_status_field_name => nil)
               .where('created_at >= ? AND created_at <= ?', params[:start_date], params[:end_date])
    leads_by_sales_group = {}
    sales_assign_tos = Field.find_by(name: sales_assign_to_field_name).field_picklist_values.pluck(:value)
    sales_lead_statuses = Field.find_by(name: sales_lead_status_field_name).field_picklist_values.pluck(:value)
    # To give 0 as initial value for group query
    sales_assign_tos.each do |sales_assign_to|
      sales_lead_statuses.each do |sales_lead_status|
        leads_by_sales_group[[sales_assign_to, sales_lead_status]] = 0
      end
    end
    @leads_by_sales_group = leads_by_sales_group.merge(@leads.group(sales_assign_to_field_name, sales_lead_status_field_name).count)
    @sales_assign_to_group = sales_assign_tos.each_with_object({}){|k, h| h[k] = 0}.merge(@leads.group(sales_assign_to_field_name).count)
    @sales_lead_statuses = sales_lead_statuses
  end

  def won_clients
    @won_clients = Client
                     .all
                     .where(sales__lead__status: 'Won ')
                     .where('created_at >= ? AND created_at <= ?', params[:start_date], params[:end_date])
  end

  # Note: This depends on dynamic fields so if deleted then it could break the application
  def marketing_lead_statistics
    @leads = Lead
               .where.not(marketing__assign__to: nil)
               .where('created_at >= ? AND created_at <= ?', params[:start_date], params[:end_date])
    @leads_by_marketing_group = @leads.group(:marketing__assign__to).count
  end

  def account_manager_performance
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_month
    @account_manager_performance = OpenStruct.new
    @account_manager_performance.start_date = start_date
    @account_manager_performance.end_date = end_date
    @account_manager_performance.records = User.all_active_users.joins(:clients).joins(clients: :audits).where(clients: { deployment_status: 'Completed' }).where("(audited_changes->'deployment_status'->(-1))::text ~ ?", 'Completed').where('audits.created_at' => @account_manager_performance.start_date...@account_manager_performance.end_date).includes(:clients)
  end
end
