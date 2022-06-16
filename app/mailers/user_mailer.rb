class UserMailer < ApplicationMailer
  helper ApplicationHelper

  def daily_ticket_reminder(user, tickets)
    @tickets_by_status = tickets.group_by{|ticket| ticket.status}
    mail(to: user.email, subject: 'Important: Ticket Task Update')
  end

  # TODO: This can be moved to workflow, once we implement multi-record workflow
  def inventory_under_stock_reminder(inventory_groups)
    @inventory_groups = inventory_groups
    mail(to: ENV['REPORT_REMINDER_EMAILS'], subject: 'Important: Low Stock Inventory')
  end
end
