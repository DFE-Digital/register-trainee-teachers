# frozen_string_literal: true

module Degrees
  class CreateFromCsvRow
    include ServicePattern

    class Error < StandardError; end

    HESA_UK_COUNTRY = "United Kingdom, not otherwise specified"

    def initialize(trainee:, csv_row:)
      @trainee = trainee
      @csv_row = csv_row
    end

    def call
      trainee.transaction do
        trainee.degrees.destroy_all
        trainee.degrees.create!(mapped_degree_attributes)
      end
    end

  private

    attr_reader :trainee, :csv_row

    def mapped_degree_attributes
      attrs = {
        subject: subject&.name,
        subject_uuid: subject&.id,
        graduation_year: csv_row["Degree: graduation year"],
        grade: degree_grade&.name,
        grade_uuid: degree_grade&.id,
      }

      if uk_country?(country)
        attrs.merge!({
          institution: institution&.name,
          institution_uuid: institution&.id,
          locale_code: "uk",
          uk_degree: uk_degree_type&.name,
          uk_degree_uuid: uk_degree_type&.id,
        })
      else
        attrs.merge!({
          locale_code: "non_uk",
          country: country,
          non_uk_degree: non_uk_degree_type,
        })
      end

      attrs
    end

    def country
      country = csv_row["Degree: country"]

      # They can provide either the country code or name
      if ["UK", "United Kingdom"].include?(country)
        HESA_UK_COUNTRY
      elsif Hesa::CodeSets::Countries::MAPPING.values.include?(country)
        country
      else
        Hesa::CodeSets::Countries::MAPPING[country]
      end
    end

    def uk_country?(country)
      Hesa::CodeSets::Countries::UK_COUNTRIES.include?(country)
    end

    def subject
      @subject ||= DfEReference::DegreesQuery.find_subject(name: raw_subject)
    end

    def raw_subject
      @raw_subject ||= csv_row["Degree: subjects"]&.split(",")&.first
    end

    # They can provide either the name or the UKPRN
    def institution
      @institution ||= begin
        institution = csv_row["Degree: UK awarding institution"]
        DfEReference::DegreesQuery.find_institution(name: institution, ukprn: institution)
      end
    end

    def degree_grade
      @degree_grade ||= DfEReference::DegreesQuery.find_grade(name: csv_row["Degree: UK grade"])
    end

    def uk_degree_type
      @uk_degree_type ||= DfEReference::DegreesQuery.find_type(name: csv_row["Degree: UK degree types"])
    end

    def non_uk_degree_type
      type = csv_row["Degree: Non-UK degree types"]&.gsub("'", "’")&.strip

      if (ENIC_NON_UK + [NON_ENIC]).include?(type)
        type
      else
        raise(Error, "Non-UK degree type not recognised: #{type}")
      end
    end
  end
end
