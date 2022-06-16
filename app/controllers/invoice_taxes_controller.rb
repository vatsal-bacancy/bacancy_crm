class InvoiceTaxesController < ApplicationController


  def index
    @taxs = InvoiceTax.all
  end

  def new
    @invoice_tax = InvoiceTax.new
  end

  def create
    @tax = InvoiceTax.new(invoice_tax_params)
    if @tax.save
      flash[:success] = "Tax successfully added"
    else
      flash[:danger] = @tax.errors.full_messages.join(",")
    end
    @taxs = InvoiceTax.all
  end

  def edit
    @invoice_tax = InvoiceTax.find(params[:id])
  end

  def update
    @tax = InvoiceTax.find(params[:id])
    if @tax.update(invoice_tax_params)
      flash[:success] = "Tax successfully updates"
    else
      flash[:danger] = @tax.errors.full_messages.join(",")
    end
    @taxs = InvoiceTax.all
  end

  def destroy
    @tax = InvoiceTax.find(params[:id])
    if @tax.destroy
      flash[:successfully] = "Tax successsully deleted"
    else
      flash[:danger] = @tax.errors.full_messages.join(",")
    end
    @taxs = InvoiceTax.all
  end

  private
  def invoice_tax_params
    params.require(:invoice_tax).permit(:name,:tax_rate)
  end


end
