class ProjectUser < ApplicationRecord
	belongs_to :user
	belongs_to :project
	#belongs_to :client

	after_create :create_unread

	def create_unread
		Unread.create(unreadable: project, resourcable: user)
	end
end
