class TemplateDirsController < ApplicationController


  def new
    @template_dir = TemplateDir.new
  end


  def create
    @template_dir = TemplateDir.new(template_dir_params)
    @template_dir.user = current_user
    if @template_dir.save
    end
    @email_templetes = EmailTemplete.where(template_dir_id: nil, user_id: current_user.id)
    @dir = TemplateDir.where(user_id: current_user.all_user_of_related_company.ids)
    @list =   @overviews = (@email_templetes + @dir).sort{|a,b| b.created_at <=> a.created_at }
  end

  def edit
    @template_dir = TemplateDir.find(params[:id])

  end

  def update
    @template_dir = TemplateDir.find(params[:id])

    if @template_dir.update(template_dir_params)
      flash[:success] = "Successfully Update"
    else
      # flash[:danger] = "Unable to Update"
      # render :edit
    end
    @email_templetes = EmailTemplete.where(template_dir_id: nil, user_id: current_user.id)
    @dir = TemplateDir.where(user_id: current_user.all_user_of_related_company.ids)
    @list =   @overviews = (@email_templetes + @dir).sort{|a,b| b.created_at <=> a.created_at }
  end

  def destroy
  end

  def show
    @template_dir = TemplateDir.find(params[:id])
    @email_templetes = @template_dir.email_templetes.where(user_id: current_user.id)
    # @dir = TemplateDir.where(user_id: current_user.all_user_of_related_company.ids)
    # @list =   @overviews = (@email_templetes + @dir).sort{|a,b| b.created_at <=> a.created_at }
  end
  private

    def template_dir_params
      params.require(:template_dir).permit(:name)
    end
end
