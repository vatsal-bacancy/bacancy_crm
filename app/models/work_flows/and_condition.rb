class WorkFlows::AndCondition < ApplicationRecord
  belongs_to :work_flow
  belongs_to :field

  enum comparator: [:is, :is_not, :starts_with, :ends_with, :contains, :does_not_contains, :is_empty, :is_not_empty, :has_changed_to, :is_changed]

  def execute(object)
    WorkFlows::ConditionExecutor.execute(object, self.field.name, self.comparator, self.value)
  end
end
