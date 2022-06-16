class Contract::TemplatesController < ApplicationController
  before_action :authenticate_user!

  def index
    @contract_templates = Contract::Template.all
  end

  def new
    contract_template
  end

  def edit
    contract_template
  end

  def show
    render json: { title: contract_template.title, description: contract_template.description }
  end

  def create
    if contract_template.update(contract_template_params)
      flash[:success] = 'Contract Template Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Contract Template!'
    end
    redirect_to contract_templates_path
  end

  def update
    if contract_template.update(contract_template_params)
      flash[:success] = 'Contract Template Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Contract Template!'
    end
    redirect_to contract_templates_path
  end

  def destroy
    if contract_template.destroy
      flash[:success] = 'Contract Template Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Contract Template!'
    end
    redirect_to contract_templates_path
  end

  private

  def contract_template
    @contract_template ||= if params[:id].present?
                             Contract::Template.find(params[:id])
                           else
                               Contract::Template.new
                           end
  end

  def contract_template_params
    params.require(:contract_template).permit(:name, :title, :description)
  end
end
