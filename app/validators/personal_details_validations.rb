# frozen_string_literal: true

module PersonalDetailsValidations
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include DatesHelper

    validates :first_names, presence: true, length: { maximum: 50 }
    validates :last_name, presence: true, length: { maximum: 50 }
    validates :middle_names, length: { maximum: 50 }, allow_nil: true
    validates :date_of_birth, presence: true
    validates :sex, presence: true, inclusion: { in: Trainee.sexes.keys + Trainee.sexes.values }
    validate :date_of_birth_valid
  end

  def date_of_birth_valid
    if !date_of_birth.is_a?(Date)
      errors.add(:date_of_birth, :invalid)
    elsif date_of_birth > Time.zone.today
      errors.add(:date_of_birth, :future)
    elsif date_of_birth.year.digits.length != 4
      errors.add(:date_of_birth, :invalid_year)
    elsif date_of_birth > 16.years.ago
      errors.add(:date_of_birth, :under16)
    elsif date_of_birth < 100.years.ago
      errors.add(:date_of_birth, :past)
    end
  end
end
