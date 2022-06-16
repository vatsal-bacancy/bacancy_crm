class Task < ApplicationRecord
  audited
  # acts_as_paranoid
  belongs_to :user
  belongs_to :taskable, polymorphic: true, optional: true
  # has_many :documents, as: :documentable, dependent: :destroy
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables

  after_create_commit :set_reminder, :send_confirmation_mail_to_user

  def get_value(field_name)
    if field_name == "attachment"
      if self.attachment.file == nil
        self.attachment.file
      else
        self.attachment.url
      end
    else
      self.send(field_name)
    end
  end

  def get_object_name
    if taskable_type == "Lead"
      Lead.find(taskable_id).company_name
    elsif taskable_type == "Client"
      Client.find(taskable_id).company_name
    elsif taskable_type == "Company"
      Company.find(taskable_id).name
    end
  end

  def set_reminder
    TaskWorker.perform_in(email_reminder, id)
  end

  def send_confirmation_mail_to_user
    MesssageWorker.perform_async(:user_task_confirmation_mail, task_id: self.id)
  end

  def send_mail
    MesssageWorker.perform_async(:task_mail, task_id: self.id ) #send details to Assigned To 
    if self.taskable_type == "Client"
      @client = Client.find(self.taskable_id)
      @contacts = @client.contacts
      @contacts.each do | contact |
        #send mail client's contact
        MesssageWorker.perform_async(:send_task_mail, contact_id: contact.id, task_id: self.id )
      end
    elsif self.taskable_type == "Lead"
      @lead = Lead.find(self.taskable_id)
      @contacts = @lead.contacts
      @contacts.each do | contact |
        #send mail lead's contact
        MesssageWorker.perform_async(:send_task_mail,contact_id: contact.id, task_id: self.id )
      end
    end
  end
end
