class CreateEmailTempletes < ActiveRecord::Migration[5.1]
  def change
    create_table :email_templetes do |t|
      t.string :name
      t.string :subject
      t.string :content
      # t.string :status

      t.string :attachment
      t.references :user, foreign_key: true
      t.references :template_dir, foreign_key: true

      t.timestamps
    end
  end
end
