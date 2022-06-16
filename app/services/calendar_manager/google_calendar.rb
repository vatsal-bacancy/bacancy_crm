module CalendarManager
  class GoogleCalendar

    def initialize(token)
      @service = get_service(token)
      @primary = 'primary'
      @timezone = 'US/Eastern' # our application timezone, (specified in application.rb)
      @send_notifications = true # Note: this option is deprecated
    end

    def insert_event(summary:, location:, description:, start_date_time:, end_date_time:, attendees_emails:)
      event = build_event(summary: summary, location: location, description: description, start_date_time: start_date_time, end_date_time: end_date_time, attendees_emails: attendees_emails)
      @service.insert_event(@primary, event, send_notifications: @send_notifications)
    end

    def update_event(id:, summary:, location:, description:, start_date_time:, end_date_time:, attendees_emails:)
      event = build_event(summary: summary, location: location, description: description, start_date_time: start_date_time, end_date_time: end_date_time, attendees_emails: attendees_emails)
      @service.update_event(@primary, id, event, send_notifications: @send_notifications)
    end

    def destroy_event(id:)
      @service.delete_event(@primary, id, send_notifications: @send_notifications)
    end

    private

    def get_service(token)
      client = Signet::OAuth2::Client.new(access_token: token)
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service
    end

    def build_event(summary:, location:, description:, start_date_time:, end_date_time:, attendees_emails:)
      attendees = attendees_emails.map do |attendee_email|
        Google::Apis::CalendarV3::EventAttendee.new(email: attendee_email)
      end
      Google::Apis::CalendarV3::Event.new(
        summary: summary,
        location: location,
        description: description,
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_date_time.rfc3339, timezone: @timezone),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_date_time.rfc3339, timezone: @timezone),
        attendees: attendees
      )
    end
  end
end
