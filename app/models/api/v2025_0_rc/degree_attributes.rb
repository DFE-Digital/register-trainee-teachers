# frozen_string_literal: true

module Api
  module V20250Rc
    class DegreeAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Api::ErrorAttributeAdapter

      attr_accessor :record_source

      ATTRIBUTES = %i[
        id
        country
        grade
        grade_uuid
        uk_degree
        uk_degree_uuid
        non_uk_degree
        subject
        subject_uuid
        institution
        institution_uuid
        graduation_year
        locale_code
        other_grade
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      attr_reader :existing_degrees

      validates :locale_code, presence: true
      validates :graduation_year, presence: true
      validates :subject, presence: true

      validates :country, inclusion: { in: Hesa::CodeSets::Countries::MAPPING.values }, allow_blank: true

      with_options if: -> { locale_code == "uk" } do
        validates :institution, presence: true
        validates :uk_degree, presence: true
        validates :uk_degree, inclusion: { in: DfEReference::DegreesQuery::TYPES.all.map(&:name) }, allow_blank: true
        validates :grade, presence: true
      end
      with_options if: -> { locale_code == "non_uk" } do
        validates :country, presence: true
        validates :non_uk_degree, presence: true
        validates :non_uk_degree, inclusion: { in: DfEReference::DegreesQuery::TYPES.all.map(&:name) }, allow_blank: true
      end

      validate :check_for_duplicates

      def self.from_degree(degree, trainee:)
        new(degree.attributes.select { |k, _v| ATTRIBUTES.include?(k.to_sym) }, trainee:)
      end

      def initialize(params, trainee: nil, record_source: nil)
        super(params)

        @existing_degrees = if trainee.present?
                              if id.present?
                                trainee.degrees.where.not(id:)
                              else
                                trainee.degrees
                              end
                            end

        self.record_source = record_source
      end

      def duplicates?
        duplicates.present?
      end

      def duplicates
        existing_degrees&.where(
          attributes.with_indifferent_access.slice(
            :subject,
            :graduation_year,
            :country,
            :uk_degree,
            :non_uk_degree,
            :grade,
          ).compact,
        )
      end

    private

      def check_for_duplicates
        errors.add(:base, :duplicate) if duplicates?
      end
    end
  end
end
