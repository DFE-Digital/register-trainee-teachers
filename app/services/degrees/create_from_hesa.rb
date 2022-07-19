# frozen_string_literal: true

module Degrees
  class CreateFromHesa
    include ServicePattern

    def initialize(trainee:, hesa_degrees:)
      @trainee = trainee
      @hesa_degrees = hesa_degrees.reject { |d| d.compact.empty? }
    end

    def call
      create_degrees!
    end

  private

    attr_reader :hesa_degrees, :trainee

    def create_degrees!
      hesa_degrees.map do |hesa_degree|
        dfe_subject = dfe_reference_subject_item(hesa_degree[:subject])
        degree = trainee.degrees.find_or_initialize_by(subject: dfe_subject.name)

        degree.subject_uuid = dfe_subject.id

        degree.graduation_year = hesa_degree[:graduation_date]&.to_date&.year

        country_specific_attributes(degree, hesa_degree)
        grade_attributes(degree, hesa_degree)

        degree.save!
        degree
      end
    end

    def country_specific_attributes(degree, hesa_degree)
      country = Hesa::CodeSets::Countries::MAPPING[hesa_degree[:country]]
      dfe_institution = dfe_reference_institution_item(hesa_degree[:institution])
      dfe_type = dfe_reference_type_item(hesa_degree[:degree_type])

      # Country code is not always provided, so we have
      # to fallback to institution which is always UK based
      if uk_country?(country) || dfe_institution
        # HESA guidance says to leave institution blank and set
        # country for UK degrees where the HESA list doesn't
        # have the institution so it may not be present for some UK degrees
        if dfe_institution
          degree.institution = dfe_institution.name
          degree.institution_uuid = dfe_institution.id
        end

        degree.locale_code = "uk"
        degree.country = nil
        degree.uk_degree = dfe_type.name
        degree.uk_degree_uuid = dfe_type.id
        degree.non_uk_degree = nil
      else
        degree.locale_code = "non_uk"
        degree.country = country
        degree.uk_degree = nil
        degree.non_uk_degree = dfe_type.name
      end
    end

    def grade_attributes(degree, hesa_degree)
      dfe_grade = dfe_reference_grade_item(hesa_degree[:grade])

      if Hesa::CodeSets::Grades::OTHER_GRADES.include?(hesa_degree[:grade])
        degree.grade = Hesa::CodeSets::Grades::OTHER
        degree.other_grade = grade.name
      else
        degree.grade = dfe_grade.name
        degree.grade_uuid = dfe_grade.id
        degree.other_grade = nil
      end
    end

    def uk_country?(country)
      Hesa::CodeSets::Countries::UK_COUNTRIES.include?(country)
    end

    def dfe_reference_subject_item(hecos_code)
      DfeReference.find_subject(hecos_code: hecos_code)
    end

    def dfe_reference_type_item(hesa_code)
      DfeReference.find_type(hesa_code: hesa_code)
    end

    def dfe_reference_institution_item(hesa_code)
      DfeReference.find_institution(hesa_code: hesa_code)
    end

    def dfe_reference_grade_item(hesa_code)
      DfeReference.find_grade(hesa_code: hesa_code)
    end
  end
end
