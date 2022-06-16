class Comment < ApplicationRecord
  # acts_as_paranoid
  audited
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  mount_uploader :attachment, AttachmentUploader

  def get_user_name(id)
    User.find(id).fullname
  end
end
