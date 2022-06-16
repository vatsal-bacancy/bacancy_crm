module HomeHelper
  def account_status_color(status)
    if status == 'Actively Processing' || status == 'Production Mode' || status == 'Active - not processing'
      'bg-lightgreen'
    elsif status == 'Account on HOLD' || status == 'In Progress'
      'bg-yellow'
    elsif status == 'Account Cancelled' || status == 'Closed by iPos' || status == 'Closed by Client'
      'bg-lightred'
    end
  end
end
