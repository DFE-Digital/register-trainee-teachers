class NestedAttributesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.is_a?(Array)
      value.each do |item|
        validate_nested_object(record, attribute, item)
      end
    else
      validate_nested_object(record, attribute, value)
    end
  end

  private

    def validate_nested_object(record, attribute, nested_object)
      return unless nested_object.present?

      unless nested_object.valid?
        nested_object.errors.each do |error|
          record.errors.add(attribute, error.full_message)
        end
      end
    end
end
