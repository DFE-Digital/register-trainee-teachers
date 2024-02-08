# frozen_string_literal: true

module Api
  class PlacementAttributes
    include ActiveModel::Model
    include ActiveModel::Attributes

    URN_REGEX = /^[0-9]{6}$/

    ATTRIBUTES = %i[
      address
      name
      postcode
      urn
      school_id
    ].freeze

    ATTRIBUTES.each do |attr|
      attribute attr
    end

    validates :name, presence: true, if: -> { school_id.blank? }
    validate :school_valid, on: %i[create update]
    validate :urn_valid
    validate :postcode_valid
  end

private

  def school_valid
    if school_id.blank? && [name, urn, postcode].all?(&:blank?)
      errors.add(:school_id, :blank)
    end
  end

  def urn_valid
    if urn.present? && !urn.match?(URN_REGEX)
      errors.add(:urn, :invalid_format)
    end
  end

  def postcode_valid
    if postcode.present? && !UKPostcode.parse(postcode).valid?
      errors.add(:postcode, I18n.t("activemodel.errors.validators.postcode.invalid"))
    end
  end
end
