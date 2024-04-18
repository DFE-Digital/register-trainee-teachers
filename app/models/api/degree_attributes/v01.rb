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
        grade_uuid
        locale_code
        uk_degree
        uk_degree_uuid
        non_uk_degree
        subject
        subject_uuid
        institution
        institution_uuid
        graduation_year
        other_grade
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      attr_reader :existing_degrees

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

      with_options allow_nil: true do
        validates :institution, inclusion: { in: DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:hesa_itt_code) }
        validates :subject, inclusion: { in: DfEReference::DegreesQuery::SUBJECTS.all.map(&:hecos_code) }
        validates :uk_degree, inclusion: { in: DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code) }
      end

      validate :check_for_duplicates

      def self.from_degree(degree, trainee:)
        new(
          DegreeSerializer::V01.new(degree).as_hash.select { |k, _v| ATTRIBUTES.include?(k.to_sym) },
          trainee:,
        )
      end

      def duplicates?
        existing_degrees&.exists?(attributes.symbolize_keys.except(:id))
      end

    private

      def check_for_duplicates
        errors.add(:base, :duplicates) if duplicates?
      end
    end
  end
end
