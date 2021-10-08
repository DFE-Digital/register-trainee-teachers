# frozen_string_literal: true

module BulkImport
  class Error < StandardError; end

  REJECTED_WORD_LIST = ["the"].freeze

  class << self
    def import_row(provider, csv_row)
      # Age range max
      # Age range min
      trainee = build_trainee(provider, csv_row)

      set_course(provider, trainee, csv_row)

      build_degrees(trainee, csv_row)

      trainee.save!
    end

    def build_degrees(trainee, csv_row)
      if csv_row["Institution"].present?
        build_uk_degree(
          trainee,
          degree_type: csv_row["Degree type"],
          grade: csv_row["Degree grade"],
          graduation_year: csv_row["Graduation year"],
          institution: csv_row["Institution"],
          subject: csv_row["Degree subject"],
        )
      end

      if csv_row["Institution 2"].present?
        build_uk_degree(
          trainee,
          degree_type: csv_row["Degree type 2"],
          grade: csv_row["Degree grade 2"],
          graduation_year: csv_row["Graduation year 2"],
          institution: csv_row["Institution 2"],
          subject: csv_row["Degree subject 2"],
        )
      end

      if csv_row["Country (Non UK) degree"].present?
        build_non_uk_degree(
          trainee,
          country: csv_row["Country (Non UK) degree"],
          non_uk_degree: csv_row["UK ENIC equivalent (Non UK)"],
          subject: csv_row["Non UK Degree subject"],
          graduation_year: csv_row["Undergrad degree date obtained (Non UK)"],
        )
      end

      if csv_row["Country (Non UK) degree 2"].present?
        build_non_uk_degree(
          trainee,
          country: csv_row["Country (Non UK) degree 2"],
          non_uk_degree: csv_row["UK ENIC equivalent (Non UK) 2"],
          subject: csv_row["Non UK Degree subject 2"],
          graduation_year: csv_row["Undergrad degree date obtained (Non UK) 2"],
        )
      end
    end

    def build_uk_degree(trainee, degree_type:, grade:, graduation_year:, institution:, subject:)
      trainee.degrees.build do |degree|
        degree.locale_code = :uk
        degree.uk_degree = validate_uk_degree(degree_type)
        degree.grade = to_degree_grade(grade)
        degree.graduation_year = graduation_year
        degree.institution = validate_degree_institution(institution)
        degree.subject = validate_degree_subject(subject)
      end
    end

    def build_non_uk_degree(trainee, country:, non_uk_degree:, subject:, graduation_year:)
      trainee.degrees.build do |degree|
        degree.locale_code = :non_uk
        degree.country = country
        degree.non_uk_degree = validate_enic_non_uk_degree(non_uk_degree)
        degree.subject = validate_degree_subject(subject)
        degree.graduation_year = Date.new(graduation_year.to_i).year if graduation_year.present?
      end
    end

    def build_trainee(provider, csv_row)
      trainee = provider.trainees.find_or_initialize_by(trainee_id: csv_row["Trainee ID"])

      assign_field = lambda do |field_name|
        lambda do |field_value|
          trainee.send("#{field_name}=", field_value)
          field_value
        end
      end

      column_mapper = {
        # "Age range" => method(:to_age_range) >> assign_field[:course_age_range],
        "Bursary funding" => method(:to_funding_boolean) >> assign_field[:applying_for_bursary],
        "Building" => assign_field[:address_line_one],
        "Course end date" => Date.method(:parse) >> assign_field[:course_end_date],
        "Course start date" => Date.method(:parse) >> assign_field[:course_start_date],
        # "Date left" => method(:parse_date) >> assign_field[:withdraw_date],
        "Date of birth" => method(:parse_date) >> assign_field[:date_of_birth],
        # "Date of deferral" => method(:parse_date) >> assign_field[:defer_date],
        "Disability" => method(:to_disability_disclosure) >> assign_field[:disability_disclosure],
        "Disability specification" => method(:to_disability_ids) >> assign_field[:disability_ids],
        "Email address" => assign_field[:email],
        "Employing school" => method(:to_school_id) >> assign_field[:employing_school_id],
        "Ethnicity" => method(:to_ethnic_group) >> assign_field[:ethnic_group],
        "First names" => assign_field[:first_names],
        "Gender" => method(:to_gender) >> assign_field[:gender],
        # "Grant funding" => method(:to_funding_boolean) >> assign_field[:applying_for_grant],
        "ITT Subject 1" => method(:to_course_subject) >> assign_field[:course_subject_one],
        "ITT Subject 2" => method(:to_course_subject) >> assign_field[:course_subject_two],
        "ITT Subject 3" => method(:to_course_subject) >> assign_field[:course_subject_three],
        "Last names" => assign_field[:last_name],
        "Lead School" => method(:to_school_id) >> assign_field[:lead_school_id],
        "Middle names" => assign_field[:middle_names],
        "Nationality" => method(:to_nationality_ids) >> assign_field[:nationality_ids],
        "Outside UK address" => assign_field[:international_address],
        "Postal code" => method(:to_post_code) >> assign_field[:postcode],
        "Route" => method(:to_route) >> assign_field[:training_route],
        "Scholarship" => method(:to_funding_boolean) >> assign_field[:applying_for_scholarship],
        "Street" => assign_field[:address_line_two],
        "Study mode" => method(:to_study_mode) >> assign_field[:study_mode],
        "Town or city" => assign_field[:town_city],
        "Trainee start date" => assign_field[:commencement_date],
        "Training initiative" => method(:to_training_initiative) >> assign_field[:training_initiative],
        # "TRN" => assign_field[:trn],
      }
      column_mapper.default = proc {}

      csv_row.each do |key, value|
        column_mapper[key].call(value)
      end

      if trainee.address_line_one.blank?
        trainee.address_line_one = trainee.address_line_two
        trainee.address_line_two = nil
      end

      if trainee.international_address.present?
        trainee.locale_code = Trainee.locale_codes[:non_uk]
        trainee.address_line_one = nil
        trainee.address_line_two = nil
        trainee.town_city = nil
        trainee.postcode = nil
      else
        trainee.locale_code = Trainee.locale_codes[:uk]

      end

      trainee.diversity_disclosure = Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      trainee.ethnic_background = Diversities::NOT_PROVIDED

      # trainee.course_education_phase = Dttp::CodeSets::AgeRanges::MAPPING.dig(trainee.course_age_range, :levels)&.first

      trainee.progress.personal_details = true
      trainee.progress.contact_details = true
      trainee.progress.degrees = true
      trainee.progress.diversity = true
      trainee.progress.funding = true
      trainee.progress.course_details = true
      trainee.progress.training_details = true
      trainee.progress.trainee_data = true
      trainee.progress.schools = true
      trainee.progress.placement_details = true

      trainee
    end

    ALL_AGE_RANGES =
      begin
        constants = AgeRange.constants
        Set.new.tap do |set|
          constants.each do |constant|
            set.add AgeRange.const_get(constant)
          end
        end
      end

    def to_age_range(raw_string)
      raw_string.scan(/\d+/).map(&:to_i).tap do |age_range|
        raise Error, "Course age range not recognised" if !ALL_AGE_RANGES.include? age_range
      end
    end

    def set_course(provider, trainee, csv_row)
      course = provider.courses.find_by(code: csv_row["Course code"])

      trainee.course_code = course&.code
      # TODO: Set subjects and friends
    end

    def to_course_subject(raw_string)
      return if raw_string.blank?

      potential_subjects = HPITT::CodeSets::CourseSubjects::MAPPING.select do |_key, values|
        values.include?(raw_string.squish)
      end

      case potential_subjects.count
      when 0
        raise Error, "Course subject not recognised: #{raw_string}"
      when 1
        potential_subjects.keys.first
      else
        raise Error, "Course subject ambiguous, multiple found: #{raw_string}"
      end
    end

    def to_study_mode(raw_string)
      return if raw_string.blank?

      COURSE_STUDY_MODES[raw_string.downcase.squish.parameterize(separator: "_").to_sym]
    end

    def to_training_initiative(raw_string)
      return if raw_string.blank?

      initiative = ROUTE_INITIATIVES_ENUMS.select do |_key, initiative|
        normalise_string(initiative.gsub("_", "")).starts_with?(normalise_string(raw_string))
      end

      initiative.values.first || ROUTE_INITIATIVES_ENUMS[:no_initiative]
    end

    def to_route(raw_string)
      routes = BulkImport::CodeSets::Routes::MAPPING.select do |key, _route|
        normalise_string(key) == normalise_string(raw_string)
      end

      raise Error, "Training route not recognised: #{raw_string}" if routes.blank?

      routes.values.first
    end

    def to_degree_grade(raw_string)
      grade = Dttp::CodeSets::Grades::MAPPING.keys.select do |mapping|
        normalise_string(mapping).starts_with? normalise_string(raw_string)
      end

      raise Error, "Degree grade not recognised: #{raw_string}" if grade.blank?

      grade
    end

    def validate_degree_subject(raw_string)
      potential_subjects = Dttp::CodeSets::DegreeSubjects::MAPPING.select do |subjects|
        subjects&.casecmp?(raw_string.squish)
      end

      case potential_subjects.count
      when 0
        raise Error, "Degree subject not recognised: #{raw_string}"
      when 1
        potential_subjects.keys.first
      else
        raise Error, "Degree subject ambiguous, multiple found: #{raw_string}"
      end
    end

    def validate_degree_institution(raw_string)
      # prioritise direct matches
      return raw_string if Dttp::CodeSets::Institutions::MAPPING.keys.include?(raw_string)

      potential_institutions = potential_institutions_in_dttp_codeset(raw_string)

      potential_institutions = potential_institutions_in_hpitt_codeset(raw_string) if potential_institutions.blank?

      case potential_institutions.count
      when 0
        Dttp::CodeSets::Institutions::OTHER_UK
      when 1
        potential_institutions.keys.first
      else
        raise Error, "Degree institution ambiguous, multiple found: #{raw_string}"
      end
    end

    def validate_uk_degree(raw_string)
      potential_degree_types = Dttp::CodeSets::DegreeTypes::MAPPING.select do |degree_name, attributes|
        degree_name&.casecmp?(raw_string.squish) || attributes[:abbreviation]&.casecmp?(raw_string.squish)
      end

      case potential_degree_types.count
      when 0
        raise Error, "Degree type not recognised: #{raw_string}"
      when 1
        potential_degree_types.keys.first
      else
        raise Error, "Degree type ambiguous, multiple found: #{raw_string}"
      end
    end

    def validate_enic_non_uk_degree(raw_string)
      return NON_ENIC if raw_string.blank?

      raw_string.tap do
        raise Error, "ENIC equivalent not recognised: #{raw_string}" if !ENIC_NON_UK.include? raw_string
      end
    end

    def to_disability_disclosure(raw_string)
      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] if normalise_string(raw_string).include?("notdisabled")

      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] if normalise_string(raw_string).include?("theydidnotsay")

      Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    end

    def to_disability_ids(raw_string)
      return [] if raw_string.blank?

      Disability.where(name: raw_string).map(&:id)
    end

    def to_school_id(raw_string)
      School.find_by_name(raw_string)&.id
    end

    def to_ethnic_group(raw_string)
      return Diversities::ETHNIC_GROUP_ENUMS[:not_provided] if raw_string.blank?

      HPITT::CodeSets::Ethnicities::MAPPING.select do |key, _value|
        normalise_string(key).starts_with?(normalise_string(raw_string))
      end.values.first

      # [raw_string.gsub(/[^a-z]/i, "").downcase].tap do |ethnic_group|
      #   raise Error, "Ethnic group not recognised: #{raw_string}" if ethnic_group.nil?
      # end
    end

    def to_funding_boolean(raw_string)
      raw_string.downcase == "yes"
    end

    def to_gender(raw_string)
      if raw_string.downcase.include?("not")
        "gender_not_provided"
      else
        raw_string.downcase
      end
    end

    def to_nationality_ids(raw_string)
      Nationality.where(name: raw_string&.downcase).ids
    end

    def to_post_code(raw_string)
      return if raw_string.blank?

      UKPostcode.parse(raw_string.gsub(/\W/, "")).to_s
    end

    def parse_date(raw_date)
      return if raw_date.blank?

      Date.parse(raw_date)
    end

    def normalise_string(raw_string)
      raw_string
      .downcase
      .gsub(/\(.*\)/, "")
      .split
      .reject { |word| REJECTED_WORD_LIST.include? word }
      .join(" ")
      .gsub(/[^\w]/, "")
    end

    def potential_institutions_in_dttp_codeset(raw_string)
      Dttp::CodeSets::Institutions::MAPPING.select do |key, _v|
        normalise_string(key) == normalise_string(raw_string)
      end
    end

    def potential_institutions_in_hpitt_codeset(raw_string)
      HPITT::CodeSets::Institutions::MAPPING.select do |_k, value|
        normalise_string(value) == normalise_string(raw_string)
      end
    end
  end
end
