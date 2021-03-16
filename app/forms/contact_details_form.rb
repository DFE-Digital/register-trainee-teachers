# frozen_string_literal: true

class ContactDetailsForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

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

  delegate :id, :persisted?, to: :trainee

  attr_accessor(*FIELDS, :fields, :trainee)

  before_validation :sanitise_email

  validates :email, presence: true
  validates :locale_code, presence: true
  validate :uk_address_valid, if: -> { uk? }
  validate :international_address_valid, if: -> { non_uk? }
  validates :postcode, postcode: true, if: ->(attr) { attr.postcode.present? }

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  def initialize(trainee, params = {}, store = FormStore)
    @trainee = trainee
    @store = store
    @new_attributes = fields_from_store.merge(params).symbolize_keys
    @fields = trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    super(fields)
  end

  def uk?
    fields[:locale_code] == "uk"
  end

  def save!
    if valid?
      update_trainee_attributes
      trainee.save!
      store.set(trainee.id, :contact_details, nil)
    else
      false
    end
  end

  def stash
    valid? && store.set(trainee.id, :contact_details, fields)
  end

private

  attr_reader :new_attributes, :store

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

  def fields_from_store
    store.get(trainee.id, :contact_details).presence || {}
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
