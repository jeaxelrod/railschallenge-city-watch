class GreaterThanZeroValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && value < 0
      record.errors[attribute] << (options[:message] || "value can't be less then 0")
    end
  end
end
