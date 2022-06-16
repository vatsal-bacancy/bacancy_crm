class MesssageMailer < ApplicationMailer

  #send msg mail to user
  def send_project_messaage_to_user(opts={})
    @message = Message.find(opts['msg_id'])
    @user_contatct = @message.resourcable_type.constantize.find(@message.resourcable_id)
    #@current_user = User.find(opts['current_user'])
    @project = Project.find(opts['project_id'])
    @user = User.find(opts['user_id'])
    sub = @message.messageable_type == "Project" ? "#{@user_contatct.fullname} has added new message on #{@project.name} project" : "#{@user_contatct.fullname} has added new comment on #{@project.name} project"
    mail(to: @user.email, subject: sub)
  end

  #send msg mail to contact
  def send_project_messaage_to_contact(opts={})
    @message = Message.find(opts['msg_id'])
    @user_contatct = @message.resourcable_type.constantize.find(@message.resourcable_id)
    #@current_user = User.find(opts['current_user'])
    @project = Project.find(opts['project_id'])
    @contact = Contact.find(opts['contact_id'])
    sub = @message.messageable_type == "Project" ? "#{@user_contatct.fullname} has added new message on #{@project.name} project" : "#{@user_contatct.fullname} has added new comment on #{@project.name} project"
    mail(to: @contact.email, subject: sub)
  end

  #task create send mail to contact
  def send_task_mail(opts={})
    @contact = Contact.find(opts[:contact_id])
    @task = Task.find(opts[:task_id])
    @user = @task.user
    mail(to: @contact.email, subject: "#{@task.title}  task added" )
  end

  #in task send details to Assigned To 
  def task_mail(opts)
    @task = Task.find(opts[:task_id])
    @user = @task.user
    mail(to: @user.email, subject: "#{@task.title}  task added")
  end

  # Ticket initial email to associated users and contacts
  def send_ticket_mail(opts = {})
    @ticket = Ticket.find(opts['ticket_id'])
    mail(to: @ticket.associated_user_and_contact_emails.join(','), subject: "iPos support: #{@ticket.ticketable.company_name} Case ##{@ticket.ticket_no}")
  end

  # Ticket message email to associated users and contacts
  def send_ticket_message_to_associated_user_and_contact(opts = {})
    @ticket = Ticket.find(opts['ticket_id'])
    @messages = @ticket.messages.ordered
    mail(to: @ticket.associated_user_and_contact_emails.join(','), subject: "iPos support: #{@ticket.ticketable.company_name} Case ##{@ticket.ticket_no}")
  end

  def user_task_confirmation_mail(opts={})
    @task = Task.find(opts[:task_id])
    @user = @task.user
    mail(to: @user.email, subject: "New task added")
  end
end
