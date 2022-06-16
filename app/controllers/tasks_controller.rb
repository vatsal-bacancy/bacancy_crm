class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @task_klass = Klass.find_by(name: "Task")
    can_perform?(@task_klass, @action_read)
    @tasks = Task.order(created_at: :desc)
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)
    @data = nil
    @from_page = 'index'
    if params[:taskable_type].present?
      @object = params[:taskable_type].constantize.find(params[:taskable_id])
    end
  end

  def new
    @task = Task.new(taskable_type: params[:taskable_type], taskable_id: params[:taskable_id])
    @task.taskable = @company unless @task.taskable.present?
    @users = User.all.active
    @taskable = @task.taskable
    @leads = Lead.all.map{|x| [x.company_name, "Lead:#{x.id}"]}
    @clients = Client.all.map{|x| [x.company_name, "Client:#{x.id}"]}
    @companies = Company.all.map{|x| [x.name, "Company:#{x.id}"]}
    @grouped_options = { "Leads" => @leads, "Clients" => @clients , "Companies" => @companies  }

    @klass = Klass.find_by(name: "Task")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def create
    @task =  Task.new(task_params)
    @task.taskable_type = params[:task][:taskable].split(":")[0]
    @task.taskable_id = params[:task][:taskable].split(":")[1]


    @task_klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)
    if @task.taskable_type  == "Lead"
      @object = Lead.find(@task.taskable_id)
    elsif @task.taskable_type  == "Client"
      @object = Client.find(@task.taskable_id)
    end
    if @task.save
      create_document(@task, params[:document_ids], params[:attachments],current_user)
      @task.send_mail #send email
      flash[:success] = 'Task successfully added'
    else
      flash[:danger] = @task.errors.full_message.join(",")
    end
    @tasks = Task.order(:id)
  end

  def show
    @task = Task.find(params[:id])
    @klass = Klass.find_by(name: "Task")
  end

  def edit
    @task = Task.find(params[:id])
    @taskable = @task.taskable

    @leads = Lead.all.map{|x| [x.company_name, "Lead:#{x.id}"]}
    @clients = Client.all.map{|x| [x.company_name, "Client:#{x.id}"]}
    @grouped_options = { "Leads" => @leads, "Clients" => @clients }

    @users = User.all.active
    @klass = Klass.find_by(name: "Task")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def update
    @task =  Task.find(params[:id])
    @task.taskable_type =  params[:task][:taskable].split(":")[0]
    @task.taskable_id =  params[:task][:taskable].split(":")[1]
    @data = nil

    @task_klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)
    if @task.taskable_type == "Lead"
      @object = Lead.find(@task.taskable_id)
    elsif @task.taskable_type == "Client"
      @object = Client.find(@task.taskable_id)
    end

    if @task.update(task_params)
      create_document(@task, params[:document_ids], params[:attachments],current_user)
      # if params[:document_ids].present?
      #   @task_documentables = @task.document_documentables
      #   document_ids = params[:document_ids].split(",").map {|i| i.to_i}.uniq
      #   document_ids.each do |doc_id|
      #     @task_documentables.find_or_create_by(document_id: doc_id)
      #   end
      #   @task_documentables.where.not(document_id: document_ids).destroy_all
      # end
      flash[:success] = 'Task successfully updated'
    else
      flash[:danger] = @task.errors.full_message.join(",")
    end
    @tasks = Task.order(:id)
  end

  def destroy
    @task = Task.find(params[:id])
    @task_klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)
    if @task.taskable_type == "Lead"
      @object = Lead.find(@task.taskable_id)
    elsif @task.taskable_type == "Client"
      @object = Client.find(@task.taskable_id)
    end
    if @task.destroy
      flash[:success] = "Task successfully deleted"
    else
      flash[:danger] = @task.errors.full_message.join(",")
    end
    @tasks = Task.all
  end

  def back_to_task
    @task = Task.find(params[:id])
    if @task.taskable_type == "Lead"
      @object = Lead.find(@task.taskable_id)
    elsif @task.taskable_type == "Client"
      @object = Client.find(@task.taskable_id)
    end
    @task_klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)
  end

  def mark_as_completed
    @task = Task.find params[:task_id]
    @task.update completed: params[:completed]
    @object = @task.taskable
    @klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @klass)
    @tasks = Task.all
  end

  def destroy_all
    @tasks = Task.where(id: params[:ids])
    if params[:taskable_type] == "Lead"
      @object = Lead.find(params[:taskable_id])
    elsif params[:taskable_type] == "Client"
      @object = Client.find(params[:taskable_id])
    end
    if @tasks.destroy_all
      flash[:success] = "Successfully deleted all"
    else
      flash[:danger] = "Enable to delete all"
    end
    @tasks = Task.all
    @task_klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)
  end

  private
  def task_params
    @klass = Klass.find_by(name: "Task")
    params.require(:task).permit(@klass.fields.pluck(:name), multi_select_params_permit(@klass))
  end
end
