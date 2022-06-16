class CreateCemails < ActiveRecord::Migration[5.1]
  def change
    create_table :cemails do |t|
      t.string :to
      t.string :cc
      t.string :bcc
      t.string :subject
      t.string :content
      #t.references :email_templete, foreign_key: true
      t.references :cemailable, polymorphic: true

      t.timestamps
    end
  end
end
