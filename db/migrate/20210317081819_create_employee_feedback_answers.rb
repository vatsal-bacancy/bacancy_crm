class CreateEmployeeFeedbackAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_feedback_answers do |t|
      t.references :employee, foreign_key: true
      t.references :feedback_question, foreign_key: true
      t.boolean :retraining, default: false
      t.timestamps
    end
  end
end
