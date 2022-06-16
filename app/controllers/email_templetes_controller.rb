class EmailTempletesController < ApplicationController

  # TODO: remove emailable_type and emailable_id because it only used for redirection (see create action)
  def new
    @email_templete = EmailTemplete.new
    @emailable_type = params[:emailable_type] if params[:emailable_type]
    @emailable_id = params[:emailable_id] if params[:emailable_id]
  end

  def index
    @klass = Klass.find_by(name: 'EmailTemplete')
    can_perform?(@klass, @action_read)

    @email_templetes = EmailTemplete.where(template_dir_id: nil, user_id: current_user.id)
    @dir = TemplateDir.where(user_id: current_user.all_user_of_related_company.ids)
    @list =   @overviews = (@email_templetes + @dir).sort{|a,b| b.created_at <=> a.created_at }
  end

  def create
    @email_templete = EmailTemplete.new(email_templete_params.merge(user_id: current_user.id))
    if @email_templete.save
      create_document(@email_templete, params[:document_ids], params[:attachments],current_user)
      flash[:success] = "Successfully save"
      if params[:email_templete][:emailable_type] == "Client"
        @client = Client.find(params[:email_templete][:emailable_id])
        redirect_to client_path(@client,email_templete: "email_templete")
      elsif params[:email_templete][:emailable_type] =="Lead"
        @lead = Lead.find(params[:email_templete][:emailable_id])
        redirect_to lead_path(@lead,email_templete: "email_templete")
      else
        redirect_to email_templetes_path
      end
      #redirect_to(:back)
    else
      flash[:danger] = "Unable to save"
      render :new
    end
  end

  def edit
    @email_templete = EmailTemplete.find(params[:id])
    @emailable_type = params[:emailable_type]
    @emailable_id = params[:emailable_id]
  end

  def update
    @email_templete = EmailTemplete.find(params[:id])
    if @email_templete.update(email_templete_params)
      create_document(@email_templete, params[:document_ids], params[:attachments],current_user)
      flash[:success] = "Successfully Update"
      redirect_to email_templetes_path
    else
      flash[:danger] = "Unable to Update"
      render :edit
    end
  end

  def destroy
    @email_temp = EmailTemplete.find(params[:id])
    @email_temp.destroy
    @email_templetes = EmailTemplete.all
  end

  def destroy_all
    @email_temp = EmailTemplete.where(id: params[:ids])
    @email_temp.destroy_all
    @email_templetes = EmailTemplete.all
  end

  private

  def email_templete_params
    params.require(:email_templete).permit(:name,:subject,:content,:status,:template_dir_id)
  end
end
