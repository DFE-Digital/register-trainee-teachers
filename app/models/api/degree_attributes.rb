# frozen_string_literal: true

module Api
  class DegreeAttributes
    include ActiveModel::Model

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

    attr_accessor(*ATTRIBUTES)

    validates :institution, inclusion: { in: DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:name) }, allow_nil: true
    validates :subject, inclusion: { in: DfEReference::DegreesQuery::SUBJECTS.all.map(&:name) }, allow_nil: true
    validates :uk_degree, inclusion: { in: DfEReference::DegreesQuery::TYPES.all.map(&:name) }, allow_nil: true
  end
end
