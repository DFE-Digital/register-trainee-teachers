# frozen_string_literal: true

class PostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless UKPostcode.parse(value).valid?
      record.errors.add(
        attribute, I18n.t(".activemodel.errors.validators.postcode.invalid")
      )
    end
  end
end
