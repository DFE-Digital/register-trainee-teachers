# frozen_string_literal: true

class Degree < ApplicationRecord
  validates :locale_code, presence: true
  validates :uk_degree, presence: true, on: :uk
  validates :country, presence: true, on: :non_uk
  validates :non_uk_degree, presence: true, on: :non_uk
  validates :subject, presence: true, on: %i[uk non_uk]
  validates :institution, presence: true, on: :uk
  validates :graduation_year, presence: true, on: %i[uk non_uk]
  validate :graduation_year_valid, if: -> { graduation_year.present? }
  validates :grade, presence: true, on: :uk

  belongs_to :trainee

  enum locale_code: { uk: 0, non_uk: 1 }

  MAX_GRAD_YEARS = 60

  def graduation_year_valid
    errors.add(:graduation_year, :future) if graduation_year > next_year
    errors.add(:graduation_year, :invalid) unless graduation_year.between?(next_year - MAX_GRAD_YEARS, next_year)
  end

  def non_uk_degree_non_naric?
    non_uk_degree == NON_NARIC
  end

private

  def next_year
    Time.zone.now.year.next
  end
end
