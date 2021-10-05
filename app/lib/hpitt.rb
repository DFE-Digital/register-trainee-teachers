# frozen_string_literal: true

module HPITT
  class Error < StandardError; end

  REJECTED_WORD_LIST = ["the"].freeze

  class << self
    def import_row(csv_row)
      trainee = build_trainee(csv_row)
      degree = build_degree(trainee, csv_row)

      trainee.save!
      degree.save!
    end

    def build_degree(trainee, csv_row)
      if csv_row["Country (Non UK) degree"].blank?
        build_uk_degree(trainee, csv_row)
      else
        build_non_uk_degree(trainee, csv_row)
      end
    end

    def build_uk_degree(trainee, row)
      Degree.new(trainee: trainee).tap do |degree|
        degree.locale_code = :uk
        degree.uk_degree = validate_uk_degree(row["Degree type"])
        degree.grade = to_degree_grade(row["Degree grade"])
        degree.graduation_year = row["Graduation year"]
        degree.institution = validate_degree_institution(row["Institution"])
        degree.subject = validate_degree_subject(row["Degree subject"])
      end
    end

    def build_non_uk_degree(trainee, row)
      Degree.new(trainee: trainee).tap do |degree|
        degree.locale_code = :non_uk
        degree.country = row["Country (Non UK) degree"]
        degree.non_uk_degree = validate_enic_non_uk_degree(row["UK ENIC equivalent (Non UK)"])
        degree.subject = validate_degree_subject(row["Subject of UG. Degree (Non UK)"])
        degree.graduation_year = Date.new(row["Undergrad degree date obtained (Non UK)"].to_i).year if row["Undergrad degree date obtained (Non UK)"].present?
      end
    end

    def build_trainee(csv_row)
      # TODO: Temporary, the provider code will need to be added to this csv
      provider = Provider.find_by!(code: TEACH_FIRST_PROVIDER_CODE)

      trainee = provider.trainees.find_or_initialize_by(trainee_id: csv_row["Trainee ID"])

      trainee.training_route = TRAINING_ROUTE_ENUMS[:hpitt_postgrad]

      assign_field = lambda do |field_name|
        lambda do |field_value|
          trainee.send("#{field_name}=", field_value)
          field_value
        end
      end

      column_mapper = {
        "Age range" => method(:to_age_range) >> assign_field[:course_age_range],
        "Building" => assign_field[:address_line_one],
        "Course end date" => Date.method(:parse) >> assign_field[:course_end_date],
        "Course start date" => Date.method(:parse) >> assign_field[:course_start_date],
        "Date left" => method(:parse_date) >> assign_field[:withdraw_date],
        "Date of birth" => method(:parse_date) >> assign_field[:date_of_birth],
        "Date of deferral" => method(:parse_date) >> assign_field[:defer_date],
        "Disability" => method(:to_disability_ids) >> assign_field[:disability_ids],
        "Email address" => assign_field[:email],
        "Employing school URN" => method(:to_school_id) >> assign_field[:employing_school_id],
        "Ethnicity" => method(:to_ethnic_group) >> assign_field[:ethnic_group],
        "First names" => assign_field[:first_names],
        "Gender" => method(:to_gender) >> assign_field[:gender],
        "ITT Subject 1" => method(:to_course_subject) >> assign_field[:course_subject_one],
        "Last names" => assign_field[:last_name],
        "Middle names" => assign_field[:middle_names],
        "Nationality" => method(:to_nationality_ids) >> assign_field[:nationality_ids],
        "Outside UK address" => assign_field[:international_address],
        "Postal code" => method(:to_post_code) >> assign_field[:postcode],
        "Region" => assign_field[:region],
        "Street" => assign_field[:address_line_two],
        "Study mode" => method(:to_study_mode) >> assign_field[:study_mode],
        "Town or city" => assign_field[:town_city],
        "Trainee start date" => assign_field[:commencement_date],
        "TRN" => assign_field[:trn],
      }
      column_mapper.default = proc {}

      # "Allocation Type" => DO we care about this?

      csv_row.each do |key, value|
        column_mapper[key].call(value)
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

      if trainee.disabilities.present?
        trainee.disability_disclosure = Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
      else
        trainee.disability_disclosure = Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability]
      end

      trainee.course_education_phase = Dttp::CodeSets::AgeRanges::MAPPING.dig(trainee.course_age_range, :levels)&.first

      trainee.training_initiative = ROUTE_INITIATIVES_ENUMS[:no_initiative]

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

    def to_course_subject(raw_string)
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
      COURSE_STUDY_MODES[raw_string.downcase.squish.parameterize(separator: "_").to_sym]
    end

    def to_degree_grade(raw_string)
      Dttp::CodeSets::Grades::MAPPING.keys.find { |mapping| mapping.casecmp? raw_string }.tap do |grade|
        raise Error, "Degree grade not recognised" if grade.blank?
      end
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
        raise Error, "Degree institution not recognised: #{raw_string}"
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
        raise Error, "ENIC equivalent not recognised" if !ENIC_NON_UK.include? raw_string
      end
    end

    def to_disability_ids(raw_string)
      return [] if raw_string.blank?

      Disability.where(name: HPITT::CodeSets::Disabilities::MAPPING[raw_string.gsub(/[^a-z]/i, "").downcase]).map(&:id)
    end

    def to_school_id(urn)
      School.find_by_urn(urn)&.id
    end

    def to_ethnic_group(raw_string)
      HPITT::CodeSets::Ethnicities::MAPPING[raw_string.gsub(/[^a-z]/i, "").downcase].tap do |ethnic_group|
        raise Error, "Ethnic group not recognised: #{raw_string}" if ethnic_group.nil?
      end
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
