class Contract::ContractsController < ApplicationController
  before_action :authenticate_user!

  def index
    @contracts = Contract::Contract.order(created_at: :desc)
  end

  def new
    contract
  end

  def edit
    contract
  end

  def create
    if contract.update(contract_params)
      flash[:success] = 'Contract Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Contract!'
    end
    redirect_to contract_contracts_path
  end

  def update
    if contract.update(contract_params)
      flash[:success] = 'Contract Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Contract!'
    end
    redirect_to contract_contracts_path
  end

  def destroy
    if contract.destroy
      flash[:success] = 'Contract Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Contract!'
    end
    redirect_to contract_contracts_path
  end

  private

  def contractable
    @contractable ||= begin
                        contractable = params[:contractable].split(':')
                        contractable[0].constantize.find(contractable[1])
                      end
  end

  def contract
    @contract ||= if params[:id].present?
                             Contract::Contract.find(params[:id])
                           else
                             contractable.contracts.new(user: current_user)
                           end
  end

  def contract_params
    params.require(:contract_contract).permit(:name, :title, :description)
  end
end
