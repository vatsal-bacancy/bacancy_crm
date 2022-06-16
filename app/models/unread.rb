class Unread < ApplicationRecord
  belongs_to :unreadable, polymorphic: true
  belongs_to :resourcable, polymorphic: true
end
