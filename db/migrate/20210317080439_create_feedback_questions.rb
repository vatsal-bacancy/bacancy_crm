class CreateFeedbackQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :feedback_questions do |t|
      t.string :title, default: ''
      t.integer :sort
      t.timestamps
    end
  end
end
