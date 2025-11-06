# frozen_string_literal: true

class AuthenticationTokenForm
  include ActiveModel::Model
  include DatesHelper

  FIELDS = %i[name day month year].freeze
  MAX_TOKEN_DURATION = 6.months

  attr_accessor(:name, :day, :month, :year, :user, :params, :authentication_token)

  validates :name, presence: true, length: { maximum: 200 }
  validates :expires_at,
            presence: true,
            date: true,
            date_relative_to_time: { future: true },
            date_future_limit: MAX_TOKEN_DURATION

  def initialize(user, params: {})
    @user   = user
    @params = params

    FIELDS.each do |field|
      instance_variable_set("@#{field}", params[field])
    end
  end

  def expires_at
    date_hash = {
      year: year || MAX_TOKEN_DURATION.from_now.year,
      month: month || MAX_TOKEN_DURATION.from_now.month,
      day: day || MAX_TOKEN_DURATION.from_now.day,
    }

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
end
