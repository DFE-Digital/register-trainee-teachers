# frozen_string_literal: true

module Degrees
  class CreateFromHesa
    include ServicePattern

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
      trainee.transaction do
        trainee.degrees.destroy_all
        hesa_degrees.each do |hesa_degree|
          next unless importable?(hesa_degree)

          subject = DfEReference.find_subject(hecos_code: hesa_degree[:subject_one])
          degree = trainee.degrees.new(
            subject: subject&.name,
            subject_uuid: subject&.id,
            graduation_year: hesa_degree[:graduation_date]&.to_date&.year,
          )

          set_country_specific_attributes(degree, hesa_degree)
          set_grade_attributes(degree, hesa_degree)

          degree.save!
        end
      end
    end

    def set_country_specific_attributes(degree, hesa_degree)
      country = Hesa::CodeSets::Countries::MAPPING[hesa_degree[:country]]
      degree_type = DfEReference.find_type(hesa_code: degree_type_hesa_code(hesa_degree))

      # Country code is not always provided, so we have to fallback to institution which is always UK based
      if uk_country?(country) || institution_hesa_code(hesa_degree).present?
        institution = find_institution(hesa_degree)

        degree.institution = institution&.name
        degree.institution_uuid = institution&.id

        degree.locale_code = "uk"
        degree.country = nil
        degree.uk_degree = degree_type&.name
        degree.uk_degree_uuid = degree_type&.id
        degree.non_uk_degree = nil
      else
        degree.locale_code = "non_uk"
        degree.country = country
        degree.uk_degree = nil
        degree.non_uk_degree = degree_type&.name
      end
    end

    def set_grade_attributes(degree, hesa_degree)
      grade = DfEReference.find_grade(hesa_code: grade_hesa_code(hesa_degree))

      degree.grade = grade&.name
      degree.grade_uuid = grade&.id
    end

    def uk_country?(country)
      country.nil? || Hesa::CodeSets::Countries::UK_COUNTRIES.include?(country)
    end

    def degree_type_hesa_code(hesa_degree)
      HONOURS_TO_NON_HONOURS_HESA_CODE_MAP[hesa_degree[:degree_type]] || hesa_degree[:degree_type]
    end

    def grade_hesa_code(hesa_degree)
      # The HESA code "09" which is "Pass - degree awarded without honours following an honours course"
      # is not currently supported by the dfe-reference gem. Falling back to the nearest equivalent.
      hesa_degree[:grade] == "09" ? "14" : hesa_degree[:grade]
    end

    def institution_hesa_code(hesa_degree)
      # HESA institution code 0133 (Institute of Education) is not listed in the dfe-reference
      # gem but it is part of University College London (0149), therefore it can be remapped.
      hesa_degree[:institution] == "0133" ? "0149" : hesa_degree[:institution]
    end

    def importable?(hesa_degree)
      hesa_degree.compact.size.positive?
    end

    def find_institution(hesa_degree)
      hesa_code = institution_hesa_code(hesa_degree)
      institution = DfEReference.find_institution(hesa_code:)

      institution || DfEReference.find_institution(name: "Other UK institution")
    end
  end
end
