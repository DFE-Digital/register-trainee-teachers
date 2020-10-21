class Degree < ApplicationRecord
  validates :locale_code, presence: true
  # validates :non_uk_degree, presence: true, if: :non_uk?
  # validates :uk_degree, presence: true, if: :uk?

  validates :degree_subject, presence: true, on: :uk
  validates :institution, presence: true, on: :uk
  validates :graduation_year, presence: true, on: :uk,
                              inclusion: { in: 1900..Time.zone.today.year }
  validates :degree_grade, presence: true, on: :uk

  validates :degree_subject, presence: true, on: :non_uk
  validates :country, presence: true, on: :non_uk
  validates :graduation_year, presence: true, on: :non_uk,
                              inclusion: { in: 1900..Time.zone.today.year }

  belongs_to :trainee

  enum locale_code: { uk: 0, non_uk: 1 }
end
