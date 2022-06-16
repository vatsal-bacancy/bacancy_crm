class ComposeEmailMailer < ApplicationMailer

  def send_compose_email(cemail,user)
    @current_user = user
    @cemail = cemail

    if @cemail.documents.present?
      @cemail.documents.each do |attach|
        attachments["#{attach.attachment.file.filename}"] = attach.attachment.read
      end
    end

    mail(form: @current_user.email, to: @cemail.to, cc: @cemail.cc&.split(","), bcc:  @cemail.bcc&.split(","), subject: @cemail.subject)
  end
end
