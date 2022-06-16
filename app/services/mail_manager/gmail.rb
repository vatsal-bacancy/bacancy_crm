module MailManager
  class Gmail

    MAILBOXES = {inbox: 'INBOX', sent: 'SENT', draft: 'DRAFT', trash: nil}.with_indifferent_access
    MAX_RESULTS = 100

    def initialize(token)
      @service = get_service(token)
      @me = 'me'
    end

    def send_user_message(to: [], cc: [], bcc: [], subject: nil, body: '', attachments: {})
      email = build_message(to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      @service.send_user_message(@me, Google::Apis::GmailV1::Message.new(raw: email.encoded))
    end

    def send_user_reply(id, body: nil)
      original_parent_email = @service.get_user_message(@me, id, format: 'RAW')
      parent_email = Mail.new(original_parent_email.raw)
      email = Mail.new
      email.to = parent_email.to
      email.subject = "Re: #{parent_email.subject}"
      email.in_reply_to = "<#{parent_email.message_id}>"
      email.html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body body
      end
      @service.send_user_message(@me,  Google::Apis::GmailV1::Message.new(raw: email.to_s, thread_id: original_parent_email.thread_id))
    end

    def get_user_message(id, mailbox)
      email = nil
      messages = []
      thread_id = @service.get_user_message(@me, id).thread_id
      ids = @service.get_user_thread(@me, thread_id, fields: 'messages(id)').messages.map{|message| message.id}
      @service.batch do |service|
        ids.each do |id|
          service.get_user_message(@me, id, format: 'RAW') do |message, err|
            messages.push(parse_message(message, mailbox, with_attachments: true))
          end
        end
      end
      unless messages.empty?
        email = messages.first
        replies = messages.drop 1
        email.replies = replies
      end
      email
    end

    def list_user_messages(mailbox)
      emails = {}
      messages = @service.list_user_messages(@me, label_ids: MAILBOXES[mailbox], max_results: MAX_RESULTS).messages || [] # UGLY
      ids = messages.map{|message| message.id}
      @service.batch do |service|
        ids.each do |id|
          service.get_user_message(@me, id, format: 'RAW') do |message, err|
            emails[message.thread_id] = parse_message(message, mailbox)
          end
        end
      end unless ids.empty?
      emails.values
    end

    def trash_user_message(id)
      @service.trash_user_message(@me, id)
    end

    # Draft
    def create_user_draft(to: [], cc: [], bcc: [], subject: nil, body: '', attachments: {})
      email = build_message(to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      draft = Google::Apis::GmailV1::Draft.new(message: Google::Apis::GmailV1::Message.new(raw: email.encoded))
      @service.create_user_draft(@me, draft)
    end

    def list_user_drafts
      emails = {}
      mailbox = :draft
      drafts = @service.list_user_drafts(@me, max_results: MAX_RESULTS).drafts || [] # UGLY
      ids = drafts.map{|draft| draft.id}
      @service.batch do |service|
        ids.each do |id|
          service.get_user_draft(@me, id, format: 'RAW') do |draft, err|
            message = draft.message
            message.id = draft.id
            emails[message.thread_id] = parse_message(message, mailbox)
          end
        end
      end unless ids.empty?
      emails.values
    end

    def get_user_draft(id)
      begin
        draft = @service.get_user_draft(@me, id, format: 'RAW')
        message = parse_message(draft.message, :draft, with_attachments: true)
        message.id = draft.id
        message
      rescue => e
        return nil
      end
    end

    def update_user_draft(id, to: [], cc: [], bcc: [], subject: nil, body: '', attachments: {})
      email = build_message(to: to, cc: cc, bcc: bcc, subject: subject, body: body, attachments: attachments)
      draft = Google::Apis::GmailV1::Draft.new(message: Google::Apis::GmailV1::Message.new(raw: email.encoded))
      @service.update_user_draft(@me, id, draft)
    end

    def send_user_draft(id)
      @service.send_user_draft(@me, Google::Apis::GmailV1::Draft.new(id: id))
    end

    def delete_user_draft(id)
      @service.delete_user_draft(@me, id)
    end

    private

    def get_service(token)
      client = Signet::OAuth2::Client.new(access_token: token)
      service = Google::Apis::GmailV1::GmailService.new
      service.authorization = client
      service
    end

    def build_message(to:, cc:, bcc:, subject:, body:, attachments:)
      email = Mail.new
      email.to = to
      email.cc = cc
      email.bcc = bcc
      email[:bcc].include_in_headers = true
      email.subject = subject
      email.html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body body
      end
      attachments.each do |filename, content|
        email.attachments[filename] = content
      end
      email
    end

    def parse_message(original_message, mailbox, with_attachments: false)
      message = Mail.new(original_message.raw)
      from_email_address = message[:from].addresses.join(', ') rescue ''
      from_name = message[:from].display_names.join(', ') rescue ''
      to_email_address = message[:to].addresses.join(', ') rescue ''
      to_name = message[:to].display_names.join(', ') rescue ''
      cc_email_address = message[:cc].addresses.join(', ') rescue ''
      bcc_email_address = message[:bcc].addresses.join(', ') rescue ''
      attachments = with_attachments ? parse_attachments(message) : {}
      Message.new(original_message.id, subject: message.subject, body: (message.html_part || message.text_part || message).decoded, from_email_address: from_email_address, from_name: from_name, to_email_address: to_email_address, to_name: to_name, received_date_time: message.date, attachments: attachments, mailbox: mailbox, cc_email_address: cc_email_address, bcc_email_address: bcc_email_address)
    end

    def parse_attachments(message)
      attachments = {}
      message.attachments.each do |attachment|
        attachments[attachment.cid] = {filename: attachment.filename, content: "data:#{attachment.content_type};base64,#{Base64.encode64(attachment.read)}"}
      end
      attachments
    end
  end
end
