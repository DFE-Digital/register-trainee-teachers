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
        subject = Hesa::CodeSets::DegreeSubjects::MAPPING[hesa_degree[:subject]]
        degree = trainee.degrees.find_or_initialize_by(subject: subject)

        degree.graduation_year = hesa_degree[:graduation_date]&.to_date&.year

        country_specific_attributes(degree, hesa_degree)
        grade_attributes(degree, hesa_degree)

        degree.save!
        degree
      end
    end

    def country_specific_attributes(degree, hesa_degree)
      country = Hesa::CodeSets::Countries::MAPPING[hesa_degree[:country]]
      institution = hesa_institution_code(hesa_degree).nil? ? nil : DfE::ReferenceData::Degrees::INSTITUTIONS.some({ hesa_itt_code: hesa_institution_code(hesa_degree) }).first
      degree_type = find_degree_type(hesa_degree[:degree_type])

      # Country code is not always provided, so we have
      # to fallback to institution which is always UK based
      if uk_country?(country) || institution
        degree.institution = institution[:name]
        degree.locale_code = "uk"
        degree.country = nil
        degree.uk_degree = degree_type
        degree.non_uk_degree = nil
        degree.institution_uuid = institution[:id]
      else
        degree.locale_code = "non_uk"
        degree.country = country
        degree.uk_degree = nil
        degree.non_uk_degree = degree_type
      end
    end

    def grade_attributes(degree, hesa_degree)
      grade = Hesa::CodeSets::Grades::MAPPING[hesa_degree[:grade]]

      if Hesa::CodeSets::Grades::OTHER_GRADES.include?(hesa_degree[:grade])
        degree.grade = Hesa::CodeSets::Grades::OTHER
        degree.other_grade = grade
      else
        degree.grade = grade
        degree.other_grade = nil
      end
    end

    def uk_country?(country)
      Hesa::CodeSets::Countries::UK_COUNTRIES.include?(country)
    end

    def find_degree_type(hesa_code)
      Dttp::CodeSets::DegreeTypes::MAPPING.find { |_, v| v[:hesa_code].to_i == hesa_code.to_i }&.first
    end

    def hesa_institution_code(hesa_degree)
      return nil if hesa_degree[:institution].nil?

      hesa_degree[:institution].to_i.to_s
    end
  end
end
