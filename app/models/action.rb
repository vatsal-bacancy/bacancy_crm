class Action < ApplicationRecord

  # We already know that we have this 4 actions
  # So we can cache it to avoid unnecessary queries
  def self.get_create
    @create ||= Action.find_by(name: 'create')
  end

  def self.get_read
    @read ||= Action.find_by(name: 'read')
  end

  def self.get_update
    @update ||= Action.find_by(name: 'update')
  end

  def self.get_delete
    @delete ||= Action.find_by(name: 'delete')
  end

  def is_create?
    self.name == 'create'
  end

  def is_read?
    self.name == 'read'
  end

  def is_update?
    self.name == 'update'
  end

  def is_delete?
    self.name == 'delete'
  end

end
