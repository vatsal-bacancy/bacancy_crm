class WorkFlows::Action::SMS < WorkFlows::Action

  VALID_EVALS = Hash.new(Hash.new).with_indifferent_access
  VALID_EVALS['Lead'] = {
    phone_number_of_lead: -> (object) { object.phone_no },
    phone_number_of_lead_contacts: -> (object) { object.contacts.pluck(:phone_no).join(',') },
    phone_number_of_lead_assigned_to: -> (object) { object.user.phone_no }
  }
  VALID_EVALS['Client'] = {
    phone_number_of_client: -> (object) { object.phone_no },
    phone_number_of_client_contacts: -> (object) { object.contacts.pluck(:phone_no).join(',') },
    phone_number_of_client_account_manager: -> (object) { object.user.phone_no }
  }
  VALID_EVALS['Ticket'] = {
    phone_number_of_users: -> (object) { object.users.pluck(:phone_no).join(',') },
    phone_number_of_contacts: -> (object) { object.users.pluck(:phone_no).join(',') }
  }
  VALID_EVALS['Meetings::Meeting'] = {
    phone_number_of_client: -> (object) { object.meetingable.phone_no },
    phone_number_of_client_contacts: -> (object) { object.meetingable.contacts.pluck(:phone_no).join(',') },
    phone_number_of_client_account_manager: -> (object) { object.meetingable.user.phone_no },
    phone_number_of_deployment_assigned_to: -> (object) { object.attendees.map{|attendee| attendee.resourceable.phone_no}.join(',') }
  }

  # used for rendering
  def valid_evals
    VALID_EVALS[self.work_flow.klass.name].keys.map{|val| [val.titleize, val]}
  end

  def execute(object)
    args_for_to = {}
    VALID_EVALS[self.work_flow.klass.name].each do |k, v|
      args_for_to[k] = v.call(object)
    end
    SMSWorker.perform_async(
      to: Mustache.render(to, args_for_to),
      body: Mustache.render(description, object) # Directly pass `object` so we can call object method from template
    )
  end
end
