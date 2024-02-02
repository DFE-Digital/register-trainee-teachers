module DateOfBirthValidatable
  extend ActiveSupport::Concern

  included do
    validates :date_of_birth, presence: true
    validate :date_of_birth_validity
  end

  private

  def date_of_birth
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
  end

  def date_of_birth_validity
    value = date_of_birth

    if !value.is_a?(Date)
      errors.add(:date_of_birth, :invalid)
    elsif value > Time.zone.today
      errors.add(:date_of_birth, :future)
    elsif value.year.digits.length != 4
      errors.add(:date_of_birth, :invalid_year)
    elsif value > 16.years.ago
      errors.add(:date_of_birth, :under16)
    elsif value < 100.years.ago
      errors.add(:date_of_birth, :past)
    end
  end

  def valid_date?(date_args)
    Date.valid_date?(*date_args)
  end
end
