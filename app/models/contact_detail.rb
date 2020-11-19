# frozen_string_literal: true

class ContactDetail
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee

  MANDATORY_UK_ADDRESS_FIELDS = %w[
    address_line_one
    town_city
    postcode
  ].freeze

  FIELDS = [
    "locale_code",
    *MANDATORY_UK_ADDRESS_FIELDS,
    "address_line_two",
    "international_address",
    "phone_number",
    "email",
  ].freeze

  delegate :id, :persisted?, to: :trainee

  attr_accessor(*FIELDS)

  validates :locale_code, presence: true
  validate :international_address_not_empty
  validate :uk_address_must_not_be_empty
  validates :postcode, postcode: true, if: ->(attr) { attr.postcode.present? }
  validates :phone_number, presence: true
  validates :phone_number, phone: true
  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def initialize(trainee)
    @trainee = trainee
    super(fields)
  end

  def fields
    trainee.attributes.slice(*FIELDS)
  end

  def save
    valid? && trainee.save
  end

private

  def international_address_not_empty
    return unless trainee.non_uk?

    if trainee.international_address.blank?
      errors.add(
        :international_address,
        :blank,
      )
    end
  end

  def uk_address_must_not_be_empty
    return unless trainee.uk?

    MANDATORY_UK_ADDRESS_FIELDS.each do |field|
      next if trainee[field.to_sym].present?

      errors.add(
        field.to_sym,
        :blank,
      )
    end
  end
end
