# frozen_string_literal: true

module HPITT
  class Error < StandardError; end

  class << self
    def import_row(csv_row)
      trainee = build_trainee(csv_row)
      degree = build_degree(trainee, csv_row)

      trainee.course_code = find_course(trainee, csv_row).code

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
        degree.institution = row["Institution"]
        degree.subject = validate_degree_subject(row["Subject of UG. degree"])
      end
    end

    def build_non_uk_degree(trainee, row)
      Degree.new(trainee: trainee).tap do |degree|
        degree.locale_code = :non_uk
        degree.country = row["Country (Non UK) degree"]
        degree.non_uk_degree = validate_enic_non_uk_degree(row["UK ENIC equivalent (Non UK)"])
        degree.subject = validate_degree_subject(row["Subject of UG. Degree (Non UK)"])
        degree.graduation_year = Date.parse(row["Undergrad degree date obtained (Non UK)"]).year
      end
    end

    def find_course(trainee, csv_row)
      potential_courses = trainee.provider.courses.where(
        duration_in_years: csv_row["Duration"].scan(/\d+/).first.to_i,
        start_date: Date.parse(csv_row["Course start date"]),
        name: csv_row["ITT Subject 1"],
        route: trainee.training_route,
      )

      case potential_courses.count
      when 0
        raise Error, "No course found"
      when 1
        potential_courses.take
      else
        raise Error, "Course ambiguous, multiple found"
      end
    end

    def build_trainee(csv_row)
      trainee = Trainee.new

      # TODO: Temporary, the provider code will need to be added to this csv
      trainee.provider = Provider.first

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
        "Date left" => Date.method(:parse) >> assign_field[:withdraw_date],
        "Date of birth" => Date.method(:parse) >> assign_field[:date_of_birth],
        "Date of deferral" => Date.method(:parse) >> assign_field[:defer_date],
        "Disability" => method(:to_disability_ids) >> assign_field[:disability_ids],
        "Email address" => assign_field[:email],
        "Employing school URN" => method(:to_school_id) >> assign_field[:employing_school_id],
        "Ethnicity" => assign_field[:ethnic_background] >> method(:to_ethnic_group) >> assign_field[:ethnic_group],
        "First names" => assign_field[:first_names],
        "Gender" => method(:to_gender) >> assign_field[:gender],
        "Last names" => assign_field[:last_name],
        "Middle names" => assign_field[:middle_names],
        "Nationality" => method(:to_nationality_ids) >> assign_field[:nationality_ids],
        "Postal code" => assign_field[:postcode],
        "Route" => method(:to_training_route) >> assign_field[:training_route],
        "Street" => assign_field[:address_line_two],
        "Town or city" => assign_field[:town_city],
        "TRN" => assign_field[:trn],
      }
      column_mapper.default = proc {}

      # "Allocation Type" => DO we care about this?

      csv_row.each do |key, value|
        column_mapper[key].call(value)
      end

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

    def to_degree_grade(raw_string)
      Dttp::CodeSets::Grades::MAPPING.keys.find { |mapping| mapping.casecmp? raw_string }.tap do |grade|
        raise Error, "Degree grade not recognised" if grade.blank?
      end
    end

    def validate_degree_subject(raw_string)
      raise Error, "Degree subject not recognised" if !Dttp::CodeSets::DegreeSubjects::MAPPING.keys.include? raw_string

      raw_string
    end

    def validate_uk_degree(raw_string)
      raw_string.tap do
        raise Error, "Degree type not recognised" if !Dttp::CodeSets::DegreeTypes::MAPPING.include? raw_string
      end
    end

    def validate_enic_non_uk_degree(raw_string)
      raw_string.tap do
        raise Error, "ENIC equivalent not recognised" if !ENIC_NON_UK.include? raw_string
      end
    end

    def to_disability_ids(raw_string)
      Disability.where(name: raw_string.split(",").map(&:strip)).map(&:id)
    end

    def to_school_id(urn)
      School.find_by_urn!(urn).id
    end

    def to_ethnic_group(ethnic_background)
      Diversities::BACKGROUNDS.find do |_, backgrounds|
        backgrounds.any? { |background| background.casecmp? ethnic_background }
      end.first
    end

    def to_gender(raw_string)
      if raw_string.downcase.include?("not")
        "gender_not_provided"
      else
        raw_string.downcase
      end
    end

    def to_nationality_ids(raw_string)
      Nationality.find_by_name!(raw_string.downcase).id
    end

    def to_training_route(raw_string)
      raw_string.parameterize.underscore.tap do |training_route|
        raise Error, "Training route not recognised" if !TRAINING_ROUTE_ENUMS.values.include? training_route
      end
    end
  end
end
