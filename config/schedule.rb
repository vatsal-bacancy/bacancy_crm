# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
set :environment, 'development'
set :output, {:error => 'log/cron.log', :standard => 'log/cron.log'}

# every 3.minutes do
#   command "rm '#{path}/log/job.log'"
# end


every :monday, at: '9am' do
  #command "rm '#{path}/log/job.log'"
  #runner "User.new.call_from_cron"
  rake "invoice_payment_reminder:send_payment_reminder"
end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
