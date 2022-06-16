class MeetingsController < ApplicationController
  before_action :authenticate_user!

  include AuthHelper

  before_action :meetingable, only: [:new, :edit, :create, :update, :destroy_all]
  before_action :rebuild_attendees, only: [:create, :update]

  def new
    @meeting = meetingable.meetings.build(title: meetingable.company_name, location: meetingable.full_address)
  end

  def edit
    @meeting = meetingable.meetings.find(params[:id])
  end

  def create
    if meeting.update(meeting_params)
      flash.now[:success] = 'Meeting Successfully Added!'
      token = get_google_access_token
      attendees_emails = meeting.emails_of_attendees
      SimpleWorker.execute do
        event = CalendarManager::GoogleCalendar.new(token).insert_event(
          summary: meeting.title,
          location: meeting.location,
          description: meeting.description,
          start_date_time: meeting.start_date_time,
          end_date_time: meeting.end_date_time,
          attendees_emails: attendees_emails
        )
        meeting.update(google_event_id: event.id)
      end
    else
      flash.now[:danger] = meeting.errors.full_messages.join(', ')
    end
  end

  def update
    if meeting.update(meeting_params)
      flash.now[:success] = 'Meeting Successfully Updated!'
      token = get_google_access_token
      attendees_emails = meeting.emails_of_attendees
      SimpleWorker.execute do
        CalendarManager::GoogleCalendar.new(token).update_event(
          id: meeting.google_event_id,
          summary: meeting.title,
          location: meeting.location,
          description: meeting.description,
          start_date_time: meeting.start_date_time,
          end_date_time: meeting.end_date_time,
          attendees_emails: attendees_emails
        )
      end
    else
      flash.now[:danger] = meeting.errors.full_messages.join(', ')
    end
  end

  def destroy
    if meeting.destroy
      flash.now[:success] = 'Meeting Successfully Deleted!'
      token = get_google_access_token
      SimpleWorker.execute do
        CalendarManager::GoogleCalendar.new(token).destroy_event(
          id: meeting.google_event_id
        )
      end
    else
      flash.now[:danger] = meeting.errors.full_messages.join(', ')
    end
  end

  def destroy_all
    meetings = Meetings::Meeting.where(id: params[:ids]).destroy_all
    token = get_google_access_token
    service = CalendarManager::GoogleCalendar.new(token)
    SimpleWorker.execute do
      meetings.each do |meeting|
        service.destroy_event(id: meeting.google_event_id)
      end
    end
  end

  def calendar
    @categories = Meetings::Meeting.categories.collect{ |c| [c.first.titleize, c.second.to_i] }
  end

  def calendar_day_meetings
    meetings = Meetings::Meeting.all.includes(:meetingable, :user, attendees: :resourceable)
    @meetings = meetings.where(date: Date.parse(params[:start_date]))
    @response = @meetings.map do |meeting|
      {
        title: meeting.title,
        start: meeting.start_date_time.rfc3339,
        end: meeting.end_date_time.rfc3339,
        url: polymorphic_path(meeting.meetingable, anchor: 'meeting'),
        start_str: meeting.start_date_time.strftime('%m/%d/%Y %I:%M %p'),
        end_str: meeting.end_date_time.strftime('%m/%d/%Y %I:%M %p'),
        start_time: meeting.start_date_time.strftime('%I:%M %p'),
        end_time: meeting.end_date_time.strftime('%I:%M %p'),
        company_name: meeting.meetingable.company_name,
        location: meeting.location,
        category: meeting.category,
        client_id: meeting.meetingable_id,
        attendees: meeting.attendees.map{|attendee| attendee.resourceable.fullname}.join(', '),
        created_by: meeting.user.fullname,
        role_of_organizer: meeting.user.role.name.titleize,
        starting_point: meeting.start_date_time.strftime('%I:00 %p')  
      }
    end
  end

  def calendar_meetings
    meetings = Meetings::Meeting.all.includes(:meetingable, :user, attendees: :resourceable)
    meetings = meetings.where(date: Date.parse(params[:start])...Date.parse(params[:end]))
    response = meetings.map do |meeting|
      {
        title: meeting.title,
        start: meeting.start_date_time.rfc3339,
        end: meeting.end_date_time.rfc3339,
        url: polymorphic_path(meeting.meetingable, anchor: 'meeting'),
        start_str: meeting.start_date_time.strftime('%m/%d/%Y %I:%M %p'),
        end_str: meeting.end_date_time.strftime('%m/%d/%Y %I:%M %p'),
        company_name: meeting.meetingable.company_name,
        location: meeting.location,
        attendees: meeting.attendees.map{|attendee| attendee.resourceable.fullname}.join(', '),
        created_by: meeting.user.fullname
      }
    end
    render json: response
  end

  private

  def meetingable
    @meetingable ||= begin
                       meetingable = params[:meetingable].split(':')
                       meetingable[0].constantize.find(meetingable[1])
                     end
  end

  def meeting
    @meeting ||= if params[:id].present?
                   Meetings::Meeting.find(params[:id])
                 else
                   meetingable.meetings.new
                 end
  end

  def rebuild_attendees
    meeting.attendees.destroy_all # TODO: improve, use nested attributes instead
    return if params[:attendees].blank?
    params[:attendees].reject_blank.map do |resourceable|
      resourceable = resourceable.split(":")
      meeting.attendees.build(resourceable_type: resourceable[0], resourceable_id: resourceable[1])
    end
  end

  def meeting_params
    params[:meeting][:user_id] = current_user.id
    params[:meeting][:category] = params[:meeting][:category].to_i
    params.require(:meeting).permit(:title, :date, :start_time, :end_time, :location, :description, :user_id, :category)
  end
end
