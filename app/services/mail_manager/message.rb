module MailManager
  class Message

    attr_accessor :id, :subject, :body
    attr_accessor :from_email_address, :from_name, :to_email_address, :to_name, :cc_email_address, :bcc_email_address
    attr_accessor :received_date_time, :mailbox
    attr_accessor :replies
    attr_accessor :attachments # attachment format should be: {"icon.png_cid": {filename: "icon.png", content: "Base64 encoded string"}}

    def initialize(id, subject: nil, body: nil, from_email_address: nil, from_name: nil, to_email_address: nil, to_name: nil, received_date_time: nil, attachments: {}, mailbox: nil, cc_email_address: nil, bcc_email_address: nil)
      self.id = id
      self.subject = subject
      self.body = body
      self.from_email_address = from_email_address
      self.from_name = from_name
      self.to_email_address = to_email_address
      self.to_name = to_name
      self.received_date_time = received_date_time
      self.mailbox = mailbox.to_sym
      self.attachments = attachments
      self.cc_email_address = cc_email_address
      self.bcc_email_address = bcc_email_address
      set_image_src_in_body
    end

    def display_name
      if mailbox == :sent
        return (to_name.split(",").reject(&:blank?).uniq.any? ? to_name : to_email_address)
      end
      from_name.present? ? from_name : from_email_address
    end

    def display_email_address
      if mailbox == :sent
        return to_email_address
      end
      from_email_address
    end

    private

    # set src of image tag to base64 string by cid(attachment)
    # remove that attachments
    # set body
    def set_image_src_in_body
      return if attachments.empty? # No need to parse body if there is no attachments present
      cids = []
      document = Nokogiri(body)
      document.css('img[src^="cid:"]').each do |img|
        cids.push(cid = img.attributes['src'].value.delete_prefix('cid:'))
        img.attributes['src'].value = attachments[cid][:content]
      end
      cids.each do |cid|
        delete_attachment(cid)
      end
      self.body=(document.to_s)
    end

    def delete_attachment(cid)
      attachments.delete(cid)
    end
  end
end
