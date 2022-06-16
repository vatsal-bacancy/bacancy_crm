module MailManager
  class Microsoft

    MAILBOXES = {inbox: 'inbox', sent: 'SentItems', draft: 'Drafts', trash: 'deletedItems'}.with_indifferent_access
    MAX_RESULTS = 100

    def initialize(token)
      @service = get_service(token)
    end

    def send_user_message(to: [], cc: [], bcc: [], subject: nil, body: '', attachments: {})
      email = build_message(to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      @service.me.send_mail(email)
    end

    def send_user_reply(id, body: nil)
      message = @service.me.messages.find(id)
      message.reply(comment: body)
    end

    def get_user_message(id, mailbox)
      email = nil
      messages = []
      thread_id = @service.me.messages.find(id).conversation_id
      @service.me.messages.filter("conversationId eq '#{thread_id}'").each do |message|
        messages.push(parse_message(message, mailbox, with_attachments: true))
      end
      unless messages.empty?
        email = messages.first
        replies = messages.drop 1
        email.replies = replies
        return email
      end
      email
    end

    def list_user_messages(mailbox)
      emails = {}
      @service.me.mail_folders.find(MAILBOXES[mailbox]).messages.order_by('receivedDateTime desc').first(MAX_RESULTS).each do |message|
        emails[message.conversation_id] = parse_message(message, mailbox)
      end
      emails.values
    end

    def trash_user_message(id)
      @service.me.messages.find(id).delete!
    end

    # Draft
    def create_user_draft(to: [], cc: [], bcc: [], subject: nil, body: '', attachments: {})
      email = build_message(to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      @service.me.messages.create(email[:message])
    end

    def list_user_drafts
      list_user_messages :draft
    end

    def get_user_draft(id)
      begin
        get_user_message id, :draft
      rescue => e
        return nil
      end
    end

    def update_user_draft(id, to: [], cc: [], bcc: [], subject: nil, body: '', attachments: {})
      email = build_message(to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      @service.me.messages.find(id).update_attributes(raw: email[:message])
    end

    def send_user_draft(id)
      @service.me.messages.find(id).send
    end

    def delete_user_draft(id)
      trash_user_message(id)
    end

    private

    def get_service(token)
      callback = Proc.new do |r|
        r.headers['Authorization'] = "Bearer #{token}"
      end
      MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0', cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'), &callback)
    end

    def build_message(to:, cc:, bcc:, subject:, body:, attachments:)
      attachments = attachments.map{|filename, content| {'@odata.type': '#microsoft.graph.fileAttachment', 'name': filename, 'contentBytes': Base64.encode64(content)}}
      to = to.map{|e| {'emailAddress': {'address': e}}}
      cc = cc.map{|e| {'emailAddress': {'address': e}}}
      bcc = bcc.map{|e| {'emailAddress': {'address': e}}}
      {
        'message': {
          'subject': subject,
          'body': {'contentType': 'HTML', 'content': body.strip},
          'toRecipients': to,
          'ccRecipients': cc,
          'bccRecipients': bcc,
          'attachments': attachments
        }
      }
    end

    def parse_message(message, mailbox, with_attachments: false)
      from_email_address = message.from.email_address.address rescue ''
      from_name = message.from.email_address.name rescue ''
      to_email_address = message.to_recipients.map{|recipient| recipient.email_address.address}.join(', ') rescue ''
      to_name = message.to_recipients.map{|recipient| recipient.email_address.name}.join(', ') rescue ''
      cc_email_address = message.cc_recipients.map{|recipient| recipient.email_address.address}.join(', ') rescue ''
      bcc_email_address = message.bcc_recipients.map{|recipient| recipient.email_address.address}.join(', ') rescue ''
      attachments = with_attachments ? parse_attachments(message) : {}
      Message.new(message.id, subject: message.subject, body: message.body.content, from_email_address: from_email_address, from_name: from_name, to_email_address: to_email_address, to_name: to_name, cc_email_address: cc_email_address, bcc_email_address: bcc_email_address, received_date_time: message.received_date_time, attachments: attachments, mailbox: mailbox)
    end

    def parse_attachments(original_message)
      attachments = {}
      original_message.attachments.each do |attachment|
        attachments[attachment.content_id] = {filename: attachment.name, content: "data:#{attachment.content_type};base64,#{attachment.content_bytes}"}
      end
      attachments
    end
  end
end
