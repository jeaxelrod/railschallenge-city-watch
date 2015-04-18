class NoChangeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.persisted? && record.send("#{attribute}_changed?")
      record.errors[attribute] << (options[:message] || "value can't be modified")
    end
  end
end
