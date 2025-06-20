# frozen_string_literal: true

module Api
  module V01
    class DegreeAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes

      include Api::ErrorMessageHelpers

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

      validates(
        :country,
        inclusion: {
          in: Hesa::CodeSets::Countries::MAPPING.values,
          message: ->(_, data) { hesa_code_inclusion_message(value: data[:value], valid_values: Hesa::CodeSets::Countries::MAPPING.keys) },
        },
        allow_blank: true,
      )

      with_options if: -> { locale_code == "uk" } do
        validates :institution, presence: true
        validates :uk_degree, presence: true
        validates :grade, presence: true
      end
      with_options if: -> { locale_code == "non_uk" } do
        validates :country, presence: true
        validates :non_uk_degree, presence: true
      end

      validates(
        :uk_degree,
        inclusion: {
          in: DfEReference::DegreesQuery::TYPES.all.map(&:name),
          message: ->(_, data) { hesa_code_inclusion_message(value: data[:value], valid_values: DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code).compact.uniq) },
          if: -> { locale_code == "uk" },
        },
        allow_blank: true,
      )

      validates(
        :non_uk_degree,
        inclusion: {
          in: DfEReference::DegreesQuery::TYPES.all.map(&:name),
          message: ->(_, data) { hesa_code_inclusion_message(value: data[:value], valid_values: DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code).compact.uniq) },
          if: -> { locale_code == "non_uk" },
        },
        allow_blank: true,
      )

      validate :check_for_duplicates

      def self.from_degree(degree, trainee:)
        new(degree.attributes.select { |k, _v| ATTRIBUTES.include?(k.to_sym) }, trainee:)
      end

      def initialize(attributes, trainee: nil)
        super(attributes)

        @existing_degrees = if trainee.present?
                              if id.present?
                                trainee.degrees.where.not(id:)
                              else
                                trainee.degrees
                              end
                            end
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
