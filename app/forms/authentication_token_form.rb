# frozen_string_literal: true

class AuthenticationTokenForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  include DatesHelper

  FIELDS = %i[name day month year].freeze

  attr_accessor(:name, :day, :month, :year, :user, :params, :authentication_token)

  validates :name, presence: true
  validate :expires_at_valid

  def initialize(user, params: {})
    @user = user
    @params = params

    FIELDS.each do |field|
      instance_variable_set("@#{field}", params[field])
    end
  end

  def expires_at
    date_hash = { year:, month:, day: }

    return nil if date_hash.values.all?(&:blank?)

    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
  end

  def save!
    if valid?
      self.authentication_token = AuthenticationToken.create_with_random_token(
        provider: user.organisation,
        created_by: user,
        name: name,
        expires_at: expires_at,
      )
    else
      false
    end
  end

private

  def expires_at_valid
    if expires_at.present? && !expires_at.is_a?(Date)
      errors.add(:expires_at, :invalid)
    end
  end
end
