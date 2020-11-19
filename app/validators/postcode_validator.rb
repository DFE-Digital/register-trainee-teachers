# frozen_string_literal: true

class PostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    postcode = UKPostcode.parse(value)
    unless postcode.full_valid?
      record.errors[attribute] << I18n.t("activemodel.errors.validators.postcode.invalid")
    end
  end
end
