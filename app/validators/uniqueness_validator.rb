# frozen_string_literal: true

class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.tally.any? { |_k, v| v > 1 }
      record.errors.add(attribute, I18n.t(".activemodel.errors.validators.uniqueness"))
    end
  end
end
