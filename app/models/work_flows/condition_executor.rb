module WorkFlows
  module ConditionExecutor

    EXECUTORS = {
      is: -> (object, attribute, value) { object.send("#{attribute}_previously_changed?") ? object.send(attribute).to_s == value : false },
      is_not: -> (object, attribute, value) { object.send(attribute).to_s != value },
      starts_with: -> (object, attribute, value) { object.send(attribute).to_s.starts_with?(value) },
      ends_with: -> (object, attribute, value) { object.send(attribute).to_s.ends_with?(value) },
      contains: -> (object, attribute, value) { object.send(attribute).to_s.include?(value) },
      does_not_contains: -> (object, attribute, value) { object.send(attribute).to_s.exclude?(value) },
      is_empty: -> (object, attribute, value) { object.send(attribute).to_s.blank? },
      is_not_empty: -> (object, attribute, value) { object.send(attribute).to_s.present? },
      has_changed_to: -> (object, attribute, value) { object.send("#{attribute}_previously_changed?") ? object.send(attribute).to_s == value : false },
      is_changed: -> (object, attribute, value) { object.send("#{attribute}_previously_changed?") }
    }.with_indifferent_access

    def self.execute(object, attribute, comparator, value)
      EXECUTORS[comparator].call(object, attribute, value)
    end
  end
end
