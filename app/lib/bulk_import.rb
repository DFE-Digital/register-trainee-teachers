# frozen_string_literal: true

module BulkImport
  class Error < StandardError; end

  REJECTED_WORD_LIST = ["the"].freeze

  FUNDING_TYPES = %i[applying_for_scholarship applying_for_grant applying_for_bursary].freeze

  class << self
    def run_pre_import_checks!(provider, csv)
      trainee_ids = csv.map { |row| row["Trainee ID"] }

      raise(Error, "Duplicate trainee ids found in csv") if trainee_ids.uniq != trainee_ids
      raise(Error, "Existing trainee ids found in database") if provider.trainees.exists?(trainee_id: trainee_ids)
    end

    def import_row(provider, csv_row)
      trainee = build_trainee(provider, csv_row)

      set_course(provider, trainee, csv_row)
      set_nationalities(trainee, csv_row)
      trainee.set_early_years_course_details
      sanitise_funding(trainee)
      build_degrees(trainee, csv_row)
      validate_and_set_progress(trainee)

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
        degree.country = validate_country(country)
        degree.non_uk_degree = validate_enic_non_uk_degree(non_uk_degree)
        degree.subject = validate_degree_subject(subject)
        degree.graduation_year = Date.new(graduation_year.to_i).year if graduation_year.present?
      end
    end

    def build_trainee(provider, csv_row)
      trainee = provider.trainees.build(trainee_id: csv_row["Trainee ID"])

      assign_field = lambda do |field_name|
        lambda do |field_value|
          trainee.send("#{field_name}=", field_value)
          field_value
        end
      end

      column_mapper = {
        "Bursary funding" => method(:to_funding) >> assign_field[:applying_for_bursary],
        "Building" => assign_field[:address_line_one],
        "Course end date" => method(:parse_date) >> assign_field[:course_end_date],
        "Course start date" => method(:parse_date) >> assign_field[:course_start_date],
        "Date of birth" => method(:parse_date) >> assign_field[:date_of_birth],
        "Disability" => method(:to_disability_disclosure) >> assign_field[:disability_disclosure],
        "Disability specification" => method(:to_disability_ids) >> assign_field[:disability_ids],
        "Email address" => assign_field[:email],
        "Employing school" => method(:to_school_id) >> assign_field[:employing_school_id],
        "Ethnicity" => method(:to_ethnic_group) >> assign_field[:ethnic_group],
        "First names" => assign_field[:first_names],
        "Gender" => method(:to_gender) >> assign_field[:gender],
        "Grant funding" => method(:to_funding) >> assign_field[:applying_for_grant],
        "ITT Subject 1" => method(:to_course_subject) >> assign_field[:course_subject_one],
        "ITT Subject 2" => method(:to_course_subject) >> assign_field[:course_subject_two],
        "ITT Subject 3" => method(:to_course_subject) >> assign_field[:course_subject_three],
        "Last names" => assign_field[:last_name],
        "Lead School" => method(:to_school_id) >> assign_field[:lead_school_id],
        "Middle names" => assign_field[:middle_names],
        "Outside UK address" => assign_field[:international_address],
        "Postal code" => method(:to_post_code) >> assign_field[:postcode],
        "Route" => method(:to_route) >> assign_field[:training_route],
        "Scholarship" => method(:to_funding) >> assign_field[:applying_for_scholarship],
        "Street" => assign_field[:address_line_two],
        "Study mode" => method(:to_study_mode) >> assign_field[:study_mode],
        "Town or city" => assign_field[:town_city],
        "Trainee start date" => assign_field[:commencement_date],
        "Training initiative" => method(:to_training_initiative) >> assign_field[:training_initiative],
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

      trainee
    end

    def set_course(provider, trainee, csv_row)
      course = provider.courses.find_by(code: csv_row["Course code"])

      return if course.blank?

      trainee.course_uuid = course.uuid

      if trainee.course_subject_one.blank?
        course_subject_one, course_subject_two, course_subject_three = CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name)).values.map(&:first).compact

        trainee.course_subject_one ||= course_subject_one
        trainee.course_subject_two ||= course_subject_two
        trainee.course_subject_three ||= course_subject_three
      end

      trainee.study_mode ||= TRAINEE_STUDY_MODE_ENUMS[course.study_mode]
      trainee.course_start_date ||= course.start_date
      trainee.course_end_date ||= course.end_date
      trainee.course_min_age ||= course.min_age
      trainee.course_max_age ||= course.max_age
      trainee.course_education_phase ||= course.level
    end

    def to_course_subject(raw_string)
      return if raw_string.blank?

      potential_subjects = HPITT::CodeSets::CourseSubjects::MAPPING.select do |_key, values|
        values.include?(raw_string.squish)
      end

      raise(Error, "Course subject not recognised: #{raw_string}") if potential_subjects.blank?

      potential_subjects.keys.first
    end

    def to_study_mode(raw_string)
      return if raw_string.blank?

      COURSE_STUDY_MODES[raw_string.downcase.squish.parameterize(separator: "_").to_sym]
    end

    def to_training_initiative(raw_string)
      return ROUTE_INITIATIVES_ENUMS[:no_initiative] if raw_string.blank?

      potential_initiative = ROUTE_INITIATIVES_ENUMS.select do |_key, initiative|
        normalise_string(initiative.gsub("_", "")).starts_with?(normalise_string(raw_string))
      end

      potential_initiative.values.first || ROUTE_INITIATIVES_ENUMS[:no_initiative]
    end

    def to_route(raw_string)
      routes = BulkImport::CodeSets::Routes::MAPPING.select do |key, _route|
        normalise_string(key) == normalise_string(raw_string)
      end

      raise(Error, "Training route not recognised: #{raw_string}") if routes.blank?

      routes.values.first
    end

    def to_degree_grade(raw_string)
      grade = Dttp::CodeSets::Grades::MAPPING.keys.select do |mapping|
        normalise_string(mapping).starts_with?(normalise_string(raw_string))
      end

      raise(Error, "Degree grade not recognised: #{raw_string}") if grade.blank?

      grade.first
    end

    def validate_degree_subject(raw_string)
      return if raw_string.blank?

      potential_subjects = Dttp::CodeSets::DegreeSubjects::MAPPING.select do |subjects|
        subjects&.casecmp?(raw_string.squish)
      end

      raise(Error, "Degree subject not recognised: #{raw_string}") if potential_subjects.blank?

      potential_subjects.keys.first
    end

    def validate_degree_institution(raw_string)
      # prioritise direct matches
      return raw_string if Dttp::CodeSets::Institutions::MAPPING.keys.include?(raw_string)

      potential_institutions = potential_institutions_in_dttp_codeset(raw_string)

      potential_institutions = potential_institutions_in_hpitt_codeset(raw_string) if potential_institutions.blank?

      return Dttp::CodeSets::Institutions::OTHER_UK if potential_institutions.blank?

      potential_institutions.keys.first
    end

    def validate_uk_degree(raw_string)
      return if raw_string.blank?

      potential_degree_types = Dttp::CodeSets::DegreeTypes::MAPPING.select do |degree_name, attributes|
        degree_name&.casecmp?(raw_string.squish) || attributes[:abbreviation]&.casecmp?(raw_string.squish)
      end

      case potential_degree_types.count
      when 0
        raise(Error, "Degree type not recognised: #{raw_string}")
      when 1
        potential_degree_types.keys.first
      else
        raise(Error, "Degree type ambiguous, #{potential_degree_types.count} found: #{raw_string}")
      end
    end

    def validate_country(raw_string)
      Dttp::CodeSets::Countries::MAPPING.keys.select do |country|
        normalise_string(country) == normalise_string(raw_string)
      end&.first
    end

    def validate_enic_non_uk_degree(raw_string)
      return NON_ENIC if raw_string.blank?

      return NON_ENIC if normalise_string(raw_string).include?("notprovided")

      ENIC_NON_UK.include?(raw_string) ? raw_string : nil
    end

    def to_disability_disclosure(raw_string)
      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] if normalise_string(raw_string).include?("notdisabled")

      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] if normalise_string(raw_string).include?("theydidnotsay")

      Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    end

    def to_disability_ids(raw_string)
      Disability.where("LOWER(name) = ?", raw_string&.downcase).ids
    end

    def to_school_id(raw_string)
      School.find_by_name(raw_string)&.id
    end

    def to_ethnic_group(raw_string)
      return Diversities::ETHNIC_GROUP_ENUMS[:not_provided] if raw_string.blank?

      HPITT::CodeSets::Ethnicities::MAPPING.select do |key, _value|
        normalise_string(key).starts_with?(normalise_string(raw_string))
      end.values.first
    end

    def to_funding(raw_string)
      return true if raw_string.downcase == "yes"

      return false if raw_string.downcase == "no"
    end

    def to_gender(raw_string)
      if raw_string.downcase.include?("not")
        "gender_not_provided"
      else
        raw_string.downcase
      end
    end

    def set_nationalities(trainee, csv_row)
      nationality_names = [csv_row["Nationality"], csv_row["Nationality (other)"]].compact.map(&:downcase)

      trainee.nationality_ids = Nationality.where(name: nationality_names).ids
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
      return "" if raw_string.blank?

      raw_string
        .downcase
        .gsub(/\(.*\)/, "")
        .split
        .reject { |word| REJECTED_WORD_LIST.include?(word) }
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

    def sanitise_funding(trainee)
      funding_manager = FundingManager.new(trainee)

      # There are instances where the provider has set more than one of funding types to "yes"
      # As we do not support that at the moment, we want to force them to make an explicit choice
      # by setting this to `nil`
      if trainee.slice(FUNDING_TYPES).values.count(true) > 1
        trainee.assign_attributes(FUNDING_TYPES.index_with { nil })
      end

      trainee.applying_for_bursary = nil if funding_manager.can_apply_for_tiered_bursary?
      trainee.applying_for_bursary = nil unless funding_manager.can_apply_for_bursary?
      trainee.applying_for_grant = nil unless funding_manager.can_apply_for_grant?
      trainee.applying_for_scholarship = nil unless funding_manager.can_apply_for_scholarship?
    end

    def validate_and_set_progress(trainee)
      TrnSubmissionForm.new(trainee: trainee).form_validators.each do |section, validator|
        section_valid = validator[:form].constantize.new(trainee).valid?
        trainee.progress.public_send("#{section}=", section_valid)
      end
    end
  end
end
