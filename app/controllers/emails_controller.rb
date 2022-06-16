class EmailsController < ApplicationController
  include AuthHelper
  include EmailsHelper

  before_action :authenticate_user!
  before_action :authenticate_user_token, except: :connect

  #TODO: remove Email.new (unused model)
  def new
    @email = Email.new
    service = get_service
    @object = service.get_user_draft(params[:message_id]) if params[:message_id]
  end

  def create
    to = params[:email]
    cc = params[:cc_email].present? ? params[:cc_email].split(',') : []
    bcc = params[:bcc_email].present? ? params[:bcc_email].split(',') : []
    subject = params[:subject]
    body = params[:message_body]
    attachments = {}
    if params[:document_ids].present?
      Document.find(params[:document_ids].split(',').uniq).each do |document|
        attachments[document.attachment.file.filename] = document.attachment.read
      end
    end
    service = get_service
    if params[:email_id].present?
        service.update_user_draft(params[:email_id], to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      service.send_user_draft(params[:email_id])
    else
      service.send_user_message(to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      handle_emailables
    end
  end

  def index
    begin
      service = get_service
      @messages = service.list_user_messages :inbox
    rescue OAuth2::Error, Google::Apis::AuthorizationError, Signet::AuthorizationError
      redirect_to connect_emails_path
    end
  end

  def sent
    begin
      service = get_service
      @messages = service.list_user_messages :sent
    rescue OAuth2::Error, Google::Apis::AuthorizationError, Signet::AuthorizationError
      redirect_to connect_emails_path
    end
  end

  def draft
    begin
      service = get_service
      @messages = service.list_user_drafts
    rescue OAuth2::Error, Google::Apis::AuthorizationError, Signet::AuthorizationError
      redirect_to connect_emails_path
    end
  end

  def create_draft
    to = params[:to]
    cc = params[:cc_email].present? ? params[:cc_email].split(',') : []
    bcc = params[:bcc_email].present? ? params[:bcc_email].split(',') : []
    subject = params[:subject]
    body = params[:body]
    attachments = {}
    if params[:document_ids].present?
      Document.find(params[:document_ids].split(',').uniq).each do |document|
        attachments[document.attachment.file.filename] = document.attachment.read
      end
    end
    service = get_service
    # @message = service.get_user_draft(params[:id])
    service.create_user_draft( to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
  end

  def update_draft
    to = params[:to]
    cc = params[:cc].present? ? params[:cc].split(',') : []
    bcc = params[:bcc].present? ? params[:bcc].split(',') : []
    subject = params[:subject]
    body = params[:body]
    attachments = {}
    if params[:document_ids].present?
      Document.find(params[:document_ids].split(',').uniq).each do |document|
        attachments[document.attachment.file.filename] = document.attachment.read
      end
    end
    service = get_service
    @message = service.get_user_draft(params[:id])
    service.update_user_draft(params[:id], to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments) if @message.present?
  end

  def destroy_draft
    service = get_service
    service.delete_user_draft(params[:id])
  end

  def show
    begin
      service = get_service
      @message = service.get_user_message(params[:id], params[:mailbox])
    rescue OAuth2::Error, Google::Apis::AuthorizationError, Signet::AuthorizationError
      redirect_to connect_emails_path
    end
  end

  def destroy
    service = get_service
    service.trash_user_message(params[:id])
  end

  #TODO: replace email_id by email
  def reply
    service = get_service
    service.send_user_reply(params[:email_id], body: params[:comment])
    @message = service.get_user_message(params[:email_id], params[:mailbox])
  end

  def connect
    @login_url = get_login_url
    @google_login_url = google_login_url
  end

  private

  def get_service
    @adapter.new(@token)
  end

  def authenticate_user_token
    if current_user.ms_azure_token
      @token = get_access_token
      @adapter = MailManager::Microsoft
    elsif current_user.google_access_token
      @token = get_google_access_token
      @adapter = MailManager::Gmail
    end
    unless @token
      redirect_to connect_emails_path
    end
  end

  def handle_emailables
    if params[:emailable_type].present?
      compose_data = { to: params[:email], cc: params[:cc_email], bcc: params[:bcc_email], content: params[:message_body], subject: params[:subject], cemailable_type: params[:emailable_type], cemailable_id: params[:emailable_id] }
      @cemail = Cemail.new(compose_data)
      @object =  params[:emailable_type].constantize.find(params[:emailable_id])
      if @cemail.save
        create_document(@cemail, params[:document_ids], params[:attachments],current_user)
        if params[:template].present?
          @email_template = EmailTemplete.find(params[:template])
          if @email_template.documents.present?
            @email_template.documents.each do |doc|
              @cemail.document_documentables.create(document_id: doc.id,resourcable: current_user)
            end
          end
        end
      end
    end
  end

end
