class UserWorker
  include Sidekiq::Worker

  def perform(method_name, args = nil)
    send(method_name, args)
  end

  def daily_ticket_reminder(args)
    User.all.find_each do |user|
      tickets = user.associated_tickets.active.created_order
      if tickets.present?
        UserMailer.daily_ticket_reminder(user, tickets).deliver
      end
    end
  end

  def inventory_under_stock_reminder(args)
    inventory_groups = InventoryGroup.all.select{ |inventory_group| inventory_group.under_stock? }
    return if inventory_groups.blank?
    UserMailer.inventory_under_stock_reminder(inventory_groups).deliver
  end

  def run_scheduled_auto_clock_out(user_id)
    user = User.find(user_id)
    User::TimeSheetLog.create_clock_out_log(user) if user.clocked_in?
  end
end
