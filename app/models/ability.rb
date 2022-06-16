# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role?(:super_admin) || user.has_role?(:admin)
      can :manage, :all
    else
      can :manage, Lead

      can :create, Task
      can [:update, :destroy], Task do |task|
        task.assigned_by == user
      end

      can :manage, Project
      can :manage, Task
      can :read, :all
      
    end
  end
end
