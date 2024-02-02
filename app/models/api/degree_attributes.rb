# frozen_string_literal: true

module Api
  class DegreeAttributes
    include ActiveModel::Model
    include DegreeValidations

    ATTRIBUTES = %i[
      id
      country
      grade
      locale_code
      uk_degree
      non_uk_degree
      subject
      institution
      graduation_year
      other_grade
    ].freeze

    enum locale_code: { uk: 0, non_uk: 1 }

    attr_accessor(*ATTRIBUTES)

    validates :locale_code, presence: true
    validates :institution, presence: true, on: :uk
    validates :country, presence: true, on: :non_uk
    validates :subject, presence: true, on: %i[uk non_uk]
    validates :uk_degree, presence: true, on: :uk
    validates :non_uk_degree, presence: true, on: :non_uk
    validates :grade, presence: true, on: :uk
    validates :graduation_year, presence: true, on: %i[uk non_uk]
    validates :institution, inclusion: { in: DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:name) }, allow_nil: true
    validates :subject, inclusion: { in: DfEReference::DegreesQuery::SUBJECTS.all.map(&:name) }, allow_nil: true
    validates :uk_degree, inclusion: { in: DfEReference::DegreesQuery::TYPES.all.map(&:name) }, allow_nil: true
  end
end
