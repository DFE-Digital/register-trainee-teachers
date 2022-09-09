# frozen_string_literal: true

module Trainees
  class CreateFromHpittCsv
    include ServicePattern

    class Error < StandardError; end

    def initialize(csv_row:)
      @csv_row = csv_row
      # TODO: Temporary, the provider code will need to be added to this csv
      @provider = Provider.find_by!(code: TEACH_FIRST_PROVIDER_CODE)
      @trainee = @provider.trainees.find_or_initialize_by(trainee_id: csv_row["Provider trainee ID"])
    end

    def call
      trainee.assign_attributes(mapped_attributes)
      Trainees::SetAcademicCycles.call(trainee: trainee)

      if trainee.save!
        ::Degrees::CreateFromHpittCsv.call(
          trainee: trainee,
          csv_row: csv_row.select { |column_name, _| column_name.start_with?("Degree:") },
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
        date_of_birth: csv_row["Date of birth"],
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

    def ethnicity_and_disability_attributes
      ethnicity_attributes.merge(disability_attributes)
                          .merge({ diversity_disclosure: diversity_disclosure })
    end

    def ethnicity_attributes
      if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
        ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

        return {
          ethnic_group: ethnic_group,
          ethnic_background: ethnic_background,
        }
      end

      {
        ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
        ethnic_background: Diversities::NOT_PROVIDED,
      }
    end

    def ethnic_background
      Hesa::CodeSets::Ethnicities::NAME_MAPPING[csv_row["Ethnicity"]]
    end

    def diversity_attributes
      attrs = {
        diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
        ethnic_background: Diversities::NOT_PROVIDED,
        ethnic_group: ethnic_group,
      }

      if csv_row["Disability"].present?
        attrs.merge({
          disability_ids: Disability.where(name: Hpitt::CodeSets::Disabilities::MAPPING[csv_row["Disability"].gsub(/[^a-z]/i, "").downcase]).map(&:id),
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
        })
      else
        attrs.merge({
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability],
        })
      end

      attrs
    end

    def disability_attributes
      if !disability_disclosed?
        return {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
        }
      end

      if disabilities == [Diversities::NO_KNOWN_DISABILITY]
        return {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability],
        }
      end

      {
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
        disabilities: disabilities.map { |disability| Disability.find_by(name: disability) },
      }
    end

    def diversity_disclosure
      if disability_disclosed? || ethnicity_disclosed?
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      else
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
      end
    end

    def disabilities
      [Hesa::CodeSets::Disabilities::NAME_MAPPING[csv_row["Disabilities"]]].compact
    end

    def disability_disclosed?
      disabilities.any? && disabilities != [Diversities::NOT_PROVIDED]
    end

    def ethnicity_disclosed?
      ethnic_background.present? && [Diversities::NOT_PROVIDED, Diversities::INFORMATION_REFUSED].exclude?(ethnic_background)
    end

    def course_attributes
      attrs = {
        course_education_phase: course_education_phase,
        course_subject_one: course_subject_one_name,
        course_subject_two: course_subject_two_name,
        course_subject_three: course_subject_three_name,
        course_age_range: course_age_range,
        study_mode: study_mode,
        itt_start_date: csv_row["Course ITT start date"],
        itt_end_date: csv_row["Course ITT end date"],
        commencement_date: csv_row["Trainee start date"],
        course_allocation_subject: course_allocation_subject,
      }

      primary_education_phase? ? fix_invalid_primary_course_subjects(attrs) : attrs
    end

    # Maybe make HESA the same?
    def primary_education_phase?
      course_age_range.last <= AgeRange::UPPER_BOUND_PRIMARY_AGE
    end

    def fix_invalid_primary_course_subjects(course_attributes)
      # This always ensures "primary teaching" is the first subject or inserts it if it's missing
      other_subjects = course_subjects - [CourseSubjects::PRIMARY_TEACHING]
      course_attributes.merge(course_subject_one: CourseSubjects::PRIMARY_TEACHING,
                              course_subject_two: other_subjects.first,
                              course_subject_three: other_subjects.second)
    end

    def course_subjects
      [course_subject_one_name, course_subject_two_name, course_subject_three_name].compact
    end

    def sex
      if csv_row["Sex"] == "Not provided"
        "gender_not_provided"
      else
        csv_row["Sex"].downcase
      end
    end

    def nationality_ids
      Nationality.where(name: csv_row["Nationality"]&.downcase).ids
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

    def course_allocation_subject
      SubjectSpecialism.find_by(name: course_subject_one_name)&.allocation_subject
    end

    def employing_school_id
      School.find_by_urn(csv_row["Employing school URN"])&.id
    end
  end
end
