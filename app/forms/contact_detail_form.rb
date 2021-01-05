# frozen_string_literal: true

class ContactDetailForm
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
    "email",
  ].freeze

  delegate :id, :persisted?, to: :trainee

  attr_accessor(*FIELDS)

  before_validation :sanitise_email

  validates :locale_code, presence: true
  validate :international_address_not_empty
  validate :uk_address_must_not_be_empty
  validates :postcode, postcode: true, if: ->(attr) { attr.postcode.present? }
  validates :email, presence: true

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  after_validation :update_trainee

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

  def update_trainee
    # Need to save the email attribute formatted by the ContactDetailForm.
    trainee.assign_attributes(fields.merge({ email: email })) if errors.empty?
  end

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

  def sanitise_email
    self.email = email.gsub(/\s+/, "") unless email.nil?
  end
end
