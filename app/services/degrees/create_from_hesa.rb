# frozen_string_literal: true

module Degrees
  class CreateFromHesa
    include ServicePattern

    UNKNOWN_DEGREE_TYPE = "999"

    # The dfe-reference gem does not include degree types with honours in
    # the name, so we need fallback to the non-honours generic degree types.
    HONOURS_TO_NON_HONOURS_HESA_CODE_MAP = {
      "002" => "001",
      "004" => "003",
      "006" => "005",
      "008" => "007",
      "010" => "009",
      # "013" => "BSc (Hons) with intercalated PGCE", # not currently available in dfe-reference-gem
      "014" => "012",
    }.freeze

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
        next unless importable?(hesa_degree)

        dfe_subject = DfeReference.find_subject(hecos_code: hesa_degree[:subject])
        degree = trainee.degrees.find_or_initialize_by(subject: dfe_subject&.name)

        degree.subject_uuid = dfe_subject&.id

        degree.graduation_year = hesa_degree[:graduation_date]&.to_date&.year

        set_country_specific_attributes(degree, hesa_degree)
        set_grade_attributes(degree, hesa_degree)

        degree.save!
        degree
      end
    end

    def set_country_specific_attributes(degree, hesa_degree)
      country = Hesa::CodeSets::Countries::MAPPING[hesa_degree[:country]]
      dfe_institution = DfeReference.find_institution(hesa_code: hesa_degree[:institution])
      dfe_type = DfeReference.find_type(hesa_code: degree_type_hesa_code(hesa_degree))

      # Country code is not always provided, so we have
      # to fallback to institution which is always UK based
      if uk_country?(country) || dfe_institution
        # HESA guidance says to leave institution blank and set
        # country for UK degrees where the HESA list doesn't
        # have the institution so it may not be present for some UK degrees
        degree.institution = dfe_institution&.name
        degree.institution_uuid = dfe_institution&.id

        degree.locale_code = "uk"
        degree.country = nil
        degree.uk_degree = dfe_type&.name
        degree.uk_degree_uuid = dfe_type&.id
        degree.non_uk_degree = nil
      else
        degree.locale_code = "non_uk"
        degree.country = country
        degree.uk_degree = nil
        degree.non_uk_degree = dfe_type&.name
      end
    end

    def set_grade_attributes(degree, hesa_degree)
      dfe_grade = DfeReference.find_grade(hesa_code: degree_grade_hesa_code(hesa_degree))

      degree.grade = dfe_grade&.name
      degree.grade_uuid = dfe_grade&.id
    end

    def uk_country?(country)
      Hesa::CodeSets::Countries::UK_COUNTRIES.include?(country)
    end

    def degree_type_hesa_code(hesa_degree)
      HONOURS_TO_NON_HONOURS_HESA_CODE_MAP[hesa_degree[:degree_type]] || hesa_degree[:degree_type]
    end

    def degree_grade_hesa_code(hesa_degree)
      # The HESA code "09" which is "Pass - degree awarded without honours following an honours course"
      # is not currently supported by the dfe-reference gem. Falling back to the nearest equivalent.
      hesa_degree[:grade] == "09" ? "14" : hesa_degree[:grade]
    end

    def importable?(hesa_degree)
      return true unless hesa_degree[:degree_type].include?(UNKNOWN_DEGREE_TYPE)

      hesa_degree.compact.size > 1
    end
  end
end
