module EmailsHelper

  def get_ms_graph(token)
    callback = Proc.new do |r|
      r.headers['Authorization'] = "Bearer #{token}"
    end
    MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0', cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'), &callback)
  end

  def get_email(object)
    if object.nil?
      return (Contact.pluck(:email) + Lead.pluck(:company_email) + Client.pluck(:company_email)).reject(&:blank?).uniq
    elsif  object.class.name == 'MailManager::Message'
      return (Contact.pluck(:email) + Lead.pluck(:company_email) + Client.pluck(:company_email) + object.to_email_address.split(",")).reject(&:blank?).uniq
    else
      ([object.company_email] + object.contacts.pluck(:email)).reject(&:blank?).uniq
    end
  end
end
