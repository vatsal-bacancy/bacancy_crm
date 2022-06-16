module Meetings
  class Attendee < ApplicationRecord
    belongs_to :meeting
    belongs_to :resourceable, polymorphic: true
  end
end
