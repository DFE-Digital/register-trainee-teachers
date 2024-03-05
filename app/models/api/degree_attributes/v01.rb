# frozen_string_literal: true

module Api
  module DegreeAttributes
    class V01
      include ActiveModel::Model
      include ActiveModel::Attributes

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

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      validates :institution, inclusion: { in: DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:name) }, allow_nil: true
      validates :subject, inclusion: { in: DfEReference::DegreesQuery::SUBJECTS.all.map(&:name) }, allow_nil: true
      validates :uk_degree, inclusion: { in: DfEReference::DegreesQuery::TYPES.all.map(&:name) }, allow_nil: true

      def self.from_degree(degree)
        new(degree.attributes.select { |k, _v| ATTRIBUTES.include?(k.to_sym) })
      end
    end
  end
end
