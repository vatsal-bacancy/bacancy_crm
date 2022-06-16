module Meetings
  class Meeting < ApplicationRecord
    include WorkFlows::Observer

    enum category: [:publicity, :technology, :finance, :sales_and_marketing]

    default_scope -> { order(date: :desc) }

    scope :last_30_days, -> { select{|meeting| (meeting.start_date_time > 31.days.ago) && (meeting.start_date_time < 1.seconds.ago)} }

    belongs_to :meetingable, polymorphic: true
    belongs_to :user

    has_many :attendees, dependent: :destroy

    validate :validate_time_range

    after_commit :broadcast_message
    after_create_commit :schedule_email
    after_create_commit :schedule_sms

    def start_date_time
      DateTime.new(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec, start_time.zone)
    end

    def end_date_time
      DateTime.new(date.year, date.month, date.day, end_time.hour, end_time.min, end_time.sec, end_time.zone)
    end

    # TODO: This `pretty_*` method are used only inside `WorkFlow` 's mustache template
    #       We can remove this and move it to template once we migrate from `mustache` to `liquid` gem
    def pretty_date
      date.try(:strftime, '%m/%d/%Y')
    end

    def pretty_start_time
      start_time.try(:strftime, '%l:%M %p')
    end

    def pretty_end_time
      end_time.try(:strftime, '%l:%M %p')
    end

    def pretty_deployment_assigned_to
      attendees.map{|attendee| attendee.resourceable.fullname}.join(', ')
    end

    def self.klass
      Klass.find_by(name: klass_name)
    end

    def self.klass_name
      'Meetings::Meeting'
    end

    def broadcast_message
      ActionCableWorker.perform_async(resource_klass: Meetings::Meeting.klass_name, resource_id: 'all')
    end

    # TODO:
    #   This `schedule_*` methods can be removed
    #   once we implement workflow that works based on the before some time field (i.e. DateTime.ago(4.hours))
    def schedule_email
      args = {
        to: self.emails_of_attendees.join(','),
        cc: nil, bcc: nil,
        subject: 'iPos Deployment/Training Schedule Reminder',
        body: Mustache.render('<!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>iPos</title>
          <meta name="viewport" content="width=device-width, minimum-scale=1.0, maximum-scale=1.0" />
          <link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700" rel="stylesheet">
          <style>
            *{ padding:0; margin:0; box-sizing: border-box;}
            body{ font-family: Poppins, sans-serif; font-size:14px; color:#2b2b2b; font-weight:normal; margin:0; padding:0;}
            table{ border:0 none; border-spacing:0;}
            th, td{ font-weight:normal;}
            img{ max-width:100%;}
          </style>
        </head>
        <body>
        <div style="background:#f2f2f2;">
          <table cellpadding="0" cellspacing="0" style="max-width:640px; margin:0 auto;">
            <tbody>
            <tr>
              <td>
                <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#fff;">
                  <tbody>
                  <tr>
                    <td style="text-align:center; padding:50px 20px;">
                      <div style="margin-bottom: 20px;">
                      <img src="https://iposcrm.com/assets/iPos-logo.png" alt="iPos logo">
                      </div>
                      <h2 style="font-family: Poppins, sans-serif; font-size:28px; color: #111111; font-weight:600; margin-bottom: 20px;">BACANCY CRM</h2>
                      <p style="font-family: Poppins, sans-serif; font-size:18px; color: #888888;">Deployment/Training Details.</p>
                    </td>
                  </tr>
                  <tr>
                    <td style="font-family: Poppins, sans-serif;  font-size:14px; color: #111111; padding:20px;">
                      <table width="100%" border="1" cellpadding="0" cellspacing="0">
                        <tbody>
                        <tr>
                          <td style="font-weight: 600; padding: 10px;">Business Name</td>
                          <td style="padding: 10px; text-align: right;">{{meetingable.company_name}}</td>
                        </tr>
                        <tr>
                          <td style="font-weight: 600; padding: 10px;">Date</td>
                          <td style="padding: 10px; text-align: right;">{{pretty_date}}</td>
                        </tr>
                        <tr>
                          <td style="font-weight: 600; padding: 10px;">Start Time</td>
                          <td style="padding: 10px; text-align: right;">{{pretty_start_time}}</td>
                        </tr>
                        <tr>
                          <td style="font-weight: 600; padding: 10px;">End Time</td>
                          <td style="padding: 10px; text-align: right;">{{pretty_end_time}}</td>
                        </tr>
                        <tr>
                          <td style="font-weight: 600; padding: 10px;">Deployment Person Name</td>
                          <td style="padding: 10px; text-align: right;">{{pretty_deployment_assigned_to}}</td>
                        </tr>
                        <tr>
                          <td style="font-weight: 600; padding: 10px;">Address</td>
                          <td style="padding: 10px; text-align: right;">{{location}}</td>
                        </tr>
                        </tbody>
                      </table>
                    </td>
                  </tr>
                  </tbody>
                </table>
              </td>
            </tr>
            <tr>
              <td style="background-color: #111111; padding:15px; text-align:center;">
                <p style=" font-size:14px; color: #fff;">iPos © 2021 All rights reserved.</p>
              </td>
            </tr>
            </tbody>
          </table>
        </div>
        </body>
        </html>
        ', self)
      }
      MailWorker.perform_in(start_date_time.ago(24.hours), args) if start_date_time.ago(24.hours) > DateTime.current
      MailWorker.perform_in(start_date_time.ago(4.hours), args) if start_date_time.ago(4.hours) > DateTime.current
    end

    def schedule_sms
      args = {
        to: self.phone_no_of_attendees.join(','),
        body: Mustache.render(
          "iPos Deployment Schedule Reminder" +
          "\nBusiness Name: {{meetingable.company_name}}" +
          "\nDate: {{pretty_date}}" +
          "\nStart Time: {{pretty_start_time}}" +
          "\nEnd Time: {{pretty_end_time}}" +
          "\nDeployment Person Name: {{pretty_deployment_assigned_to}}", self)
      }
      SMSWorker.perform_in(start_date_time.ago(24.hours), args) if start_date_time.ago(24.hours) > DateTime.current
      SMSWorker.perform_in(start_date_time.ago(4.hours), args) if start_date_time.ago(4.hours) > DateTime.current
    end

    def emails_of_attendees
      self.meetingable.contacts.pluck(:email) + [self.meetingable.user.email] + self.attendees.map{|attendee| attendee.resourceable.email}
    end

    def phone_no_of_attendees
      self.meetingable.contacts.pluck(:phone_no) + [self.meetingable.user.phone_no] + self.attendees.map{|attendee| attendee.resourceable.phone_no}
    end

    private

    def validate_time_range
      self.errors.add(:time_range, 'is not valid') if start_time > end_time
    end

    # To solve routing related problems
    def self.model_name
      ActiveModel::Name.new('Meetings::Meeting', nil, "Meeting")
    end
  end
end
