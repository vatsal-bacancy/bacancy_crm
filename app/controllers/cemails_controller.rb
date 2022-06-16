class CemailsController < ApplicationController

  def new
    @template = EmailTemplete.all
    @cemail = Cemail.new(cemailable_type: params[:cemailable_type], cemailable_id: params[:cemailable_id])
    if params[:cemailable_type] == "Lead"
      @object = Lead.find(params[:cemailable_id])
    elsif params[:cemailable_type] == "Client"
      @object = Client.find(params[:cemailable_id])
    end
  end

  def create
    @cemail = Cemail.new(params_cemail)
    if @cemail.save
      #send mail
      create_document(@cemail, params[:document_ids], params[:attachments],current_user)
      if params[:template].present?
        @email_template = EmailTemplete.find(params[:template])
        if @email_template.documents.present?
          @email_template.documents.each do |doc|
            @cemail.document_documentables.create(document_id: doc.id, resourcable: current_user)
            # @document = Document.new(documentable_type: @cemail.class.name, documentable_id: @cemail.id, user_id: current_user.id, attachment: attach.attachment)
            # @document.save
          end
        end
      end

      # params[:document_ids].split(",").map {|i| i.to_i}.uniq.each do |doc_id|
      #   @cemail.document_documentables.create(document_id: doc_id)
      # end
      # if params[:cemail][:attachment].present?
      #   params[:cemail][:attachment].each do |attach|
      #     @document = Document.new(documentable_type: @cemail.class.name, documentable_id: @cemail.id, user_id: current_user.id, attachment: attach)
      #     @document.save
      #   end
      # end

      ComposeEmailWorker.perform_async(@cemail.id,current_user.id)
      if @cemail.cemailable_type == "Lead"
        @object = Lead.find(@cemail.cemailable_id)
      elsif @cemail.cemailable_type == "Client"
        @object = Client.find(@cemail.cemailable_id)
      end
      flash[:success] = "Successfully send email"
    end
  end

  def show
    @cemail = Cemail.find(params[:id])
  end

  def destroy
    @cemail = Cemail.find(params[:id])
    if @cemail.cemailable_type == "Lead"
      @object = Lead.find(@cemail.cemailable_id)
    elsif @cemail.cemailable_type == "Client"
      @object = Client.find(@cemail.cemailable_id)
    end
    @cemail.destroy
    flash[:success] = "Successfully deleted"
  end

  def destroy_all
    @cemails = Cemail.where(id: params[:ids])
    #@cemails.destroy_all
    if params[:cemailable_type] == "Lead"
      @object = Lead.find(params[:cemailable_id])
    elsif params[:cemailable_type] == "Client"
      @object = Client.find(params[:cemailable_id])
    end
    if @cemails.destroy_all
      flash[:success] = "Successfully deleted all"
    else
      flash[:danger] = "Enable to delete all"
    end
  end

  def get_template
    @email_temp = EmailTemplete.find_by(id: params[:id])
    unless @email_temp
      render json: {subject: '',content: '', signature: current_user&.signature&.html_safe}
    else
      @subject = @email_temp.subject
      @content = @email_temp.content
      if @email_temp.documents.present?
        @attach = []
        @email_temp.documents.each do |doc|
          @attach << [doc.attachment.file.filename, doc.attachment.url]
        end
        #@attach = @email_temp.documents
        render json: { id: @email_temp.id, subject: @subject, content: @content, attachment: @attach, signature: current_user.signature ?  current_user&.signature&.html_safe : "" }
      else
        render json: { id: @email_temp.id, subject: @subject, content: @content, signature:  current_user&.signature&.html_safe }
      end
    end
  end

  def back_to_email
    @cemail = Cemail.find(params[:id])
    if @cemail.cemailable_type == "Lead"
      @object = Lead.find(@cemail.cemailable_id)
    elsif @cemail.cemailable_type == "Client"
      @object = Client.find(@cemail.cemailable_id)
    end
  end

  private
  def params_cemail
    params.require(:cemail).permit(:to,:cc,:bcc, :subject, :content, :cemailable_type, :cemailable_id)
  end

end
