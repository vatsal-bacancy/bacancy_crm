class WorkFlows::Action::Mail < WorkFlows::Action

  VALID_EVALS = Hash.new(Hash.new).with_indifferent_access
  VALID_EVALS['Lead'] = {
    email_of_lead: -> (object) { object.company_email },
    emails_of_lead_contacts: -> (object) { object.contacts.pluck(:email).join(',') },
    email_of_lead_assigned_to: -> (object) { object.user.email }
  }
  VALID_EVALS['Client'] = {
    email_of_client: -> (object) { object.company_email },
    emails_of_client_contacts: -> (object) { object.contacts.pluck(:email).join(',') },
    email_of_client_account_manager: -> (object) { object.user.email }
  }
  VALID_EVALS['Ticket'] = {
    emails_of_users: -> (object) { object.users.pluck(:email).join(',') },
    emails_of_contacts: -> (object) { object.users.pluck(:email).join(',') }
  }
  VALID_EVALS['Meetings::Meeting'] = {
    email_of_client: -> (object) { object.meetingable.company_email },
    email_client_contacts: -> (object) { object.meetingable.contacts.pluck(:email).join(',') },
    email_of_client_account_manager: -> (object) { object.meetingable.user.email },
    email_of_deployment_assigned_to: -> (object) { object.attendees.map{|attendee| attendee.resourceable.email}.join(',') }
  }

  # used for rendering
  def valid_evals
    VALID_EVALS[self.work_flow.klass.name].keys.map{|val| [val.titleize, val]}
  end

  def execute(object)
    mustache_args = {}
    VALID_EVALS[self.work_flow.klass.name].each do |k, v|
      mustache_args[k] = v.call(object)
    end
    MailWorker.perform_async(
      to: Mustache.render(to, mustache_args),
      cc: Mustache.render(cc, mustache_args),
      bcc: Mustache.render(bcc, mustache_args),
      subject: Mustache.render(subject, object), # Directly pass `object` so we can call object method from template
      body: Mustache.render(description, object) # Directly pass `object` so we can call object method from template
    )
  end
end
