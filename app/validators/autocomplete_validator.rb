# frozen_string_literal: true

class AutocompleteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    raw_value = record.send("#{attribute}_raw")
    # The form must have been submitted without the text field being on the page,
    # likely through js being disabled
    return if raw_value.nil?

    value = record.send(attribute)
    unless value == raw_value
      record.errors.add(attribute, I18n.t("activemodel.errors.validators.autocomplete.#{attribute}"))
    end
  end
end
