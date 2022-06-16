module ProjectDocumentsHelper

  def document(project)
    pro_doc = project.document_documentables.map{|doc| { project => doc } }
    msg_doc = (project.messages.map{ |msg| msg.document_documentables.map{ |doc| {msg => doc} } }).flatten
    com_doc = (project.messages.map{ |msg| msg.messages.map{ |com| com.document_documentables.map{ |doc| { com => doc } } } }).flatten
    data = pro_doc + msg_doc + com_doc
    data.group_by{ |hash| hash.values[0].created_at.to_date }.sort_by{|date,data| date}.reverse
  end
end
