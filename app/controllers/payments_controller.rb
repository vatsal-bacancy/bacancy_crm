class PaymentsController < ActionController::Base
  before_action :authenticate_user!, only: [:index]
  include AuthorizeNet::API

  def index
  end

  def new
    @invoice = Invoice.find(params[:invoice_id])
    if @invoice.paid?
      redirect_to invoice_payment_path(invoice_id: @invoice.id)
    end
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    if !@invoice.paid?
      transaction = Transaction.new(ENV['PAYMENT_LOGIN'], ENV['PAYMENT_KEY'], gateway: :sandbox)

      request = CreateTransactionRequest.new
      request.transactionRequest = TransactionRequestType.new()
      request.transactionRequest.amount = @invoice.amount_with_tax
      request.transactionRequest.payment = PaymentType.new
      request.transactionRequest.payment.creditCard = CreditCardType.new(params[:card_number], params[:card_expiry].split("/").join, params[:card_cvv])
      request.transactionRequest.customer = CustomerDataType.new(CustomerTypeEnum::Individual,"CUST-1234","bmc@mail.com",DriversLicenseType.new("DrivLicenseNumber123","WA","05/05/1990"),"123456789")
      card_holder_name = params[:card_holder_name].split
      request.transactionRequest.billTo = CustomerAddressType.new(card_holder_name[0], card_holder_name[1], @invoice.client.company_name, @invoice.client.street_address, @invoice.client.city, @invoice.client.state, params[:postal_code], "USA", @invoice.client.phone_no, nil)
      request.transactionRequest.shipTo = NameAndAddressType.new("firstNameST","lastNameST","companyST","addressST","New York","NY","10010","USA")
      request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
      request.transactionRequest.order = OrderType.new(@invoice.id, "Order Description")
      request.transactionRequest.tax = ExtendedAmountType.new("0","Sales tax","Local municipality sales tax")
      request.transactionRequest.shipping = ExtendedAmountType.new("0","Shipping charges","Ultra-fast 3 day shipping")
      lineItemArr = Array.new
      @invoice.invoice_inventories.each do |item|
        lineItem = LineItemType.new(item.inventory.id, item.inventory.name, item.description, item.qty, item.rate, (item.tax != 0).to_s)
        lineItemArr.push(lineItem)
      end
      request.transactionRequest.lineItems = LineItems.new(lineItemArr)
      userFieldArr = Array.new
      requestUserField = UserField.new("userFieldName","userFieldvalue")
      userFieldArr.push(requestUserField)
      request.transactionRequest.userFields = UserFields.new(userFieldArr)

      response = transaction.create_transaction(request)
      @payment = @invoice.payments.create(response: Marshal::dump(response))

      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          if response.transactionResponse != nil && response.transactionResponse.messages != nil
            @payment.update(successful: true)
            @invoice.create_pdf
          else
            #puts "Transaction Failed"
            if response.transactionResponse.errors != nil
              #puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
              #puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
            end
            #render json: "Error Message: #{response.transactionResponse.errors.errors[0].errorText}" #remove
          end
        else
          #puts "Transaction Failed"
          if response.transactionResponse != nil && response.transactionResponse.errors != nil
            #puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
            #puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
          else
            #puts "Error Code: #{response.messages.messages[0].code}"
            #puts "Error Message: #{response.messages.messages[0].text}"
          end
          #render json: "Error Message: #{response.messages.messages[0].text}" #remove
        end
      else
        #puts "Response is null"
        #raise "Failed to charge card."
      end
      if @payment.successful
        redirect_to invoices_path
      else
        flash[:danger] = "Payment fail"
        #render 'new'
        redirect_to new_invoice_payment_path(@invoice)
      end
    end
  end

end
