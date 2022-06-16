class MarkSomeFieldAsSystemField < ActiveRecord::Migration[5.2]
  def up
    { 'Inventory' => ['name', 'buy_price', 'sell_price', 'sku'],
      'Note' => ['content', 'created_at', 'user_id'],
      'Project' => ['name', 'status', 'start_date', 'end_date', 'client_id'],
      'Task' => ['title', 'user_id', 'due_to', 'email_reminder', 'note', 'type_task', 'get_object_name'],
      'Ticket' => ['category', 'priority', 'title', 'status', 'created_at', 'ticketable_company_name']
    }.each do |klass_name, field_names|
      Klass.find_by(name: klass_name).fields.where(name: field_names).update_all(system_field: true)
    end
  end

  def down
  end
end
