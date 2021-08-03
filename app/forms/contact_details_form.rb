# frozen_string_literal: true

class ContactDetailsForm < TraineeForm
  MANDATORY_UK_ADDRESS_FIELDS = %i[
    address_line_one
    town_city
    postcode
  ].freeze

  FIELDS = %i[
    locale_code
    address_line_two
    international_address
    email
  ].concat(MANDATORY_UK_ADDRESS_FIELDS).freeze

  attr_accessor(*FIELDS)

  before_validation :sanitise_email

  validates :locale_code, presence: true, on: %i[save missing_data]
  validate :uk_address_valid, if: -> { uk? }
  validate :international_address_valid, if: -> { non_uk? }
  validates :postcode, postcode: true, if: ->(attr) { attr.postcode.present? }
  validates :email, presence: true

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  def uk?
    fields[:locale_code] == "uk"
  end

  def save!
    if valid?(:save)
      update_trainee_attributes
      trainee.save!
      store.set(trainee.id, :contact_details, nil)
    else
      false
    end
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def non_uk?
    fields[:locale_code] == "non_uk"
  end

  def update_trainee_attributes
    nullify_unused_address_fields!
    # Need to save the email attribute formatted by the ContactDetailsForm.
    trainee.assign_attributes(fields.merge(email: email))
  end

  def sanitise_email
    self.email = email.gsub(/\s+/, "") unless email.nil?
  end

  def nullify_unused_address_fields!
    if uk?
      fields.merge!(international_address: nil)
    else
      fields.merge!(address_line_one: nil, address_line_two: nil, town_city: nil, postcode: nil)
    end
  end

  def international_address_valid
    errors.add(:international_address, :blank) if fields[:international_address].blank?
  end

  def uk_address_valid
    MANDATORY_UK_ADDRESS_FIELDS.each do |field|
      next if fields[field].present?

      errors.add(field, :blank)
    end
  end
end
