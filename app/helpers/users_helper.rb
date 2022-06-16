module UsersHelper

  def users_array
    User.active.map{|u| [u.fullname, u.id]}
  end
end
