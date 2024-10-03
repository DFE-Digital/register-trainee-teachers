# frozen_string_literal: true

module Degrees
  class CreateFromCsvRow
    include ServicePattern

    class Error < StandardError; end

    HESA_UK_COUNTRY = "United Kingdom, not otherwise specified"
    OTHER = "Other:"

    def initialize(trainee:, csv_row:)
      @trainee = trainee
      @csv_row = csv_row
    end

    def call
      return if country.blank?

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
        graduation_year: lookup("Degree: graduation year"),
        grade: degree_grade&.name,
        grade_uuid: degree_grade&.id,
      }

      if other_degree_grade
        attrs.merge!({
          grade: "Other",
          other_grade: other_degree_grade,
        })
      end

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
      country = lookup("Degree: country")

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
      @raw_subject ||= lookup("Degree: subjects")&.split(",")&.first
    end

    # They can provide either the name or the UKPRN
    def institution
      @institution ||= begin
        institution = lookup("Degree: UK awarding institution")
        DfEReference::DegreesQuery.find_institution(name: institution, ukprn: institution)
      end
    end

    def degree_grade
      @degree_grade ||= DfEReference::DegreesQuery.find_grade(name: lookup("Degree: UK grade"))
    end

    def other_degree_grade
      return @other_degree_grade if defined?(@other_degree_grade)

      @other_degree_grade =
        if lookup("Degree: UK grade")&.starts_with?("#{Diversities::OTHER}:")
          lookup("Degree: UK grade").split("#{Diversities::OTHER}:").last.strip
        end
    end

    def uk_degree_type
      @uk_degree_type ||= DfEReference::DegreesQuery.find_type(name: lookup("Degree: UK degree types"))
    end

    def non_uk_degree_type
      type = lookup("Degree: Non-UK degree types")&.gsub("'", "’")&.strip

      if (ENIC_NON_UK + [NON_ENIC]).include?(type)
        type
      else
        raise(Error, "Non-UK degree type not recognised: #{type}")
      end
    end

    def lookup(*column_names)
      column_names.each do |column_name|
        normalized_column = normalize(column_name)
        csv_row.each_key do |key|
          return csv_row[key] if normalize(key) == normalized_column
        end
      end
      nil
    end

    def normalize(str)
      return if str.blank?

      str.to_s.downcase.strip
         .gsub(/\s+/, "_")
         .gsub("-", "_")
         .gsub(":", "")
         .singularize
    end
  end
end
