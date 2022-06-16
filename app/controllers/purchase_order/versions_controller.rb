class PurchaseOrder::VersionsController < ApplicationController
  before_action :authenticate_user!

  def show
    purchase_order
    respond_to do |wants|
      wants.pdf do
        render pdf: purchase_order.purchase_orderable.company_name,
               page_size: 'A4',
               footer: { right: 'Page: [page]', center: "ipointofsale.com" },
               layout: "pdf.html",
               lowquality: true,
               zoom: 1,
               dpi: 75,
               disposition: 'attachment'
      end
    end
  end

  def create
    if purchase_order.update(purchase_order_params)
      flash[:success] = 'Purchase Order Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Purchase Order!'
    end
    redirect_to polymorphic_path(purchase_order.purchase_orderable, anchor: 'purchase-order-tab')
  end

  private

  def purchase_order
    @purchase_order ||= if params[:id].present?
                          PurchaseOrder::Version.find params[:id]
                        else
                          PurchaseOrder::Version.new(created_by: current_user)
                        end
  end

  def purchase_order_params
    params.require(:purchase_order_version).permit(:notes, :financed_hardware_total, :financed_payment_year_plan, :financed_software_total, :financed_promotional_discount, :financed_due_from_agent, :financed_total, :financed_monthly_total, :upfront_hardware_total, :upfront_promotional_discount, :upfront_promotional_discount_code, :upfront_due_from_client, :upfront_due_from_agent, :upfront_total, :purchase_orderable_type, :purchase_orderable_id, devices: {})
  end
end
