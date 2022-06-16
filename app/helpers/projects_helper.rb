module ProjectsHelper

  def recent_messages(project)
    messages_arr = []
    messages = {}
    Message.where(messageable_type: 'Project', messageable_id: project).limit(5).order(created_at: :desc).each do |message|
      messages[message.created_at] = message
      Message.where(messageable_id: message.id).each do |m|
        messages[m.created_at] = m
      end
    end
    messages.keys.sort.reverse.each do |k|
      messages_arr.push(messages[k])
    end
    messages_arr.first(5)
  end

  def all_messages(project)
    messages_arr = []
    messages = {}
    Message.where(messageable_type: 'Project', messageable_id: project).order(created_at: :desc).each do |message|
      messages[message.created_at] = message
      Message.where(messageable_id: message.id).each do |m|
        messages[m.created_at] = m
      end
    end
    messages.keys.sort.reverse.each do |k|
      messages_arr.push(messages[k])
    end
    messages_arr
  end

  def find_client(client)
    client = Client.find(client)
    client.company_name
  end

  def project_overview(project)
    comment = []
    project.messages.each do |com|
      if com.messages
        com.messages.each do |data|
          comment << data
        end
      end
    end
    (project.messages + project.document_documentables +  comment  + project.messages.map{ |msg| msg.document_documentables}).flatten.sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
  end
end
