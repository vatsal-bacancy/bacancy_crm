class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.string :category
      t.string :priority
      t.string :title
      t.references :user
      t.string :status
      t.string :description
      # t.string :solution
      t.string :ticket_no
      t.string :attachment

      t.timestamps
    end
  end
end
