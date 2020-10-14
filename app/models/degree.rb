class Degree < ApplicationRecord
  validates :locale_code, presence: true
  validates :uk_degree, presence: true, if: :uk?
  validates :non_uk_degree, presence: true, if: :non_uk?

  belongs_to :trainee

  enum locale_code: { uk: 0, non_uk: 1 }
end
