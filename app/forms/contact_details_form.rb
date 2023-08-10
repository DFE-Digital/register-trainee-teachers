# frozen_string_literal: true

class ContactDetailsForm < TraineeForm
  FIELDS = %i[email].freeze

  attr_accessor(*FIELDS)

  before_validation :sanitise_email
  validates :email, presence: true

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  def save!
    if valid?
      update_trainee_attributes
      Trainees::Update.call(trainee:)
      store.set(trainee.id, :contact_details, nil)
    else
      false
    end
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def update_trainee_attributes
    # Need to save the email attributes formatted by the ContactDetailsForm.
    trainee.assign_attributes(fields.merge(email:))
  end

  def sanitise_email
    self.email = email.gsub(/\s+/, "") unless email.nil?
  end
end
