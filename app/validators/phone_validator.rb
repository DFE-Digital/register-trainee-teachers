# frozen_string_literal: true

class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank? || is_invalid_phone_number_format?(value)
      record.errors[attribute] << I18n.t("activemodel.errors.validators.phone_number.invalid")
    end
  end

private

  def is_invalid_phone_number_format?(value)
    value.match?(/[^ext()+\. 0-9]/)
  end
end
