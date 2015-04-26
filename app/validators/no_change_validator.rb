class NoChangeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    return unless record.persisted? && record.send("#{attribute}_changed?")
    record.errors[attribute] << (options[:message] || "value can't be modified")
  end
end
