class Degree < ApplicationRecord
  validates :locale_code, presence: true
  validates :uk_degree, presence: true, on: :uk
  validates :country, presence: true, on: :non_uk
  validates :non_uk_degree, presence: true, on: :non_uk
  validates :degree_subject, presence: true, on: %i[uk non_uk]
  validates :institution, presence: true, on: :uk
  validates :graduation_year, presence: true, on: %i[uk non_uk],
                              inclusion: { in: 1900..Time.zone.today.year }
  validates :degree_grade, presence: true, on: :uk

  belongs_to :trainee

  enum locale_code: { uk: 0, non_uk: 1 }
end
