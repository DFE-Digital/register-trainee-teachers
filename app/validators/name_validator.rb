# frozen_string_literal: true

class NameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value =~ /\A([A-Za-z]+[\d]+[\w]*|[\d]+[A-Za-z]+[\w]*)|[A-Za-zÀ-ÖØ-öø-ÿ, '-]+\z/
      record.errors.add(attribute, :invalid)
    end
  end
end

