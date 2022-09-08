# frozen_string_literal: true

module Degrees
  class CreateFromHpittCsv
    include ServicePattern

    HESA_UK_COUNTRY = "United Kingdom, not otherwise specified"

    def initialize(trainee:, csv_row:)
      @trainee = trainee
      @csv_row = csv_row
    end

    def call
      trainee.degrees.create!(mapped_degree_attributes)
    end

  private

    attr_reader :trainee, :csv_row

    def mapped_degree_attributes
      subject = ::Degrees::DfeReference.find_subject(name: csv_row["Degree: subjects"])
      degree_institution = ::Degrees::DfeReference.find_institution(name: csv_row["Degree: UK awarding institution"])
      degree_type = ::Degrees::DfeReference.find_type(name: csv_row["Degree: UK degree types"])
      degree_grade = ::Degrees::DfeReference.find_grade(name: csv_row["Degree: UK grade"])

      attrs = {
        subject: subject&.name,
        subject_uuid: subject&.id,
        graduation_year: csv_row["Degree: graduation year"],
        grade: degree_grade&.name,
        grade_uuid: degree_grade&.id,
      }

      if uk_country?(degree_country)
        attrs.merge!({
          institution: degree_institution&.name,
          institution_uuid: degree_institution&.id,
          locale_code: "uk",
          uk_degree: degree_type&.name,
          uk_degree_uuid: degree_type&.id,
        })
      else
        attrs.merge!({
          locale_code: "non_uk",
          country: degree_country,
          # Not sure about this
          non_uk_degree: degree_type&.name,
        })
      end

      attrs
    end

    def degree_country
      raw_country = csv_row["Degree: country"]

      # They can provide either the country code or name
      if ["UK", "United Kingdom"].include?(raw_country)
        HESA_UK_COUNTRY
      elsif Hesa::CodeSets::Countries::MAPPING.values.include?(raw_country)
        raw_country
      else
        Hesa::CodeSets::Countries::MAPPING[raw_country]
      end
    end

    def uk_country?(country)
      Hesa::CodeSets::Countries::UK_COUNTRIES.include?(country)
    end
  end
end
