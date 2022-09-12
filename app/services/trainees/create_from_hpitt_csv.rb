# frozen_string_literal: true

module Trainees
  class CreateFromHpittCsv
    include ServicePattern
    include HasDiversityAttributes
    include HasCourseAttributes

    class Error < StandardError; end

    def initialize(csv_row:)
      @csv_row = csv_row
      @provider = Provider.find_by!(code: TEACH_FIRST_PROVIDER_CODE)
      @trainee = @provider.trainees.find_or_initialize_by(trainee_id: csv_row["Provider trainee ID"])
    end

    def call
      trainee.assign_attributes(mapped_attributes)
      Trainees::SetAcademicCycles.call(trainee: trainee)

      if trainee.save!
        ::Degrees::CreateFromHpittCsv.call(
          trainee: trainee,
          csv_row: csv_row.to_hash.compact.select { |column_name, _| column_name.start_with?("Degree:") },
        )
      end
    end

  private

    attr_reader :csv_row, :trainee

    def mapped_attributes
      {
        record_source: RecordSources::MANUAL,
        region: csv_row["Region"],
        training_route: TRAINING_ROUTE_ENUMS[:hpitt_postgrad],
        first_names: csv_row["First names"],
        middle_names: csv_row["Middle name"],
        last_name: csv_row["Last name"],
        gender: sex,
        date_of_birth: Date.parse(csv_row["Date of birth"]),
        nationality_ids: nationality_ids,
        email: csv_row["Email"],
        training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
        employing_school_id: employing_school_id,
        progress: Progress.new(
          personal_details: true,
          contact_details: true,
          degrees: true,
          diversity: true,
          funding: true,
          course_details: true,
          training_details: true,
          trainee_data: true,
          trainee_start_status: true,
          schools: true,
        ),
      }.merge(address_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
    end

    def address_attributes
      if csv_row["Outside UK address"].present?
        {
          locale_code: Trainee.locale_codes[:non_uk],
          international_address: csv_row["Outside UK address"],
        }
      else
        {
          locale_code: Trainee.locale_codes[:uk],
          address_line_one: csv_row["UK address: Line 1"],
          address_line_two: csv_row["UK address: Line 2"],
          town_city: csv_row["UK address: town or city"],
          postcode: postcode,
        }
      end
    end

    def postcode
      raw_postcode = csv_row["UK Address 1: Postcode"]
      return if raw_postcode.blank?

      UKPostcode.parse(raw_postcode.gsub(/\W/, "")).to_s
    end

    def ethnic_background
      Hesa::CodeSets::Ethnicities::NAME_MAPPING[csv_row["Ethnicity"]]
    end

    def disabilities
      disabilities = csv_row["Disabilities"].split(",").map(&:strip)
      disabilities.map { |disability| Hesa::CodeSets::Disabilities::NAME_MAPPING[disability] }.compact
    end

    def itt_start_date
      csv_row["Course ITT start date"]
    end

    def itt_end_date
      csv_row["Course ITT end date"]
    end

    def trainee_start_date
      csv_row["Trainee start date"]
    end

    def sex
      if csv_row["Sex"] == "Not provided"
        "gender_not_provided"
      else
        csv_row["Sex"].downcase
      end
    end

    def nationality_ids
      Nationality.where(name: csv_row["Nationality"]&.strip&.downcase).ids
    end

    def course_education_phase
      csv_row["Course education phase"].downcase
    end

    def course_subject_one_name
      course_subject_name("Course ITT subject 1")
    end

    def course_subject_two_name
      course_subject_name("Course ITT subject 2")
    end

    def course_subject_three_name
      course_subject_name("Course ITT subject 3")
    end

    def course_subject_name(field)
      course_subject = csv_row[field]
      return if course_subject.blank?

      subject_specialism = SubjectSpecialism.where("lower(name) = ?", course_subject.downcase).first

      if subject_specialism.present?
        subject_specialism.name
      else
        raise(Error, "Course subject not recognised: #{course_subject}")
      end
    end

    def course_age_range
      age_range = csv_row["Course age range"].split(" to ").map(&:to_i)

      if valid_age_ranges.include?(age_range)
        age_range
      else
        raise(Error, "Course age range not recognised: #{age_range}")
      end
    end

    def valid_age_ranges
      Set.new.tap do |set|
        AgeRange.constants.each do |constant|
          set.add(AgeRange.const_get(constant))
        end
      end
    end

    def study_mode
      csv_row["Course study mode"].downcase.gsub("-", "_")
    end

    def employing_school_id
      School.find_by(urn: csv_row["Employing school URN"])&.id
    end
  end
end
