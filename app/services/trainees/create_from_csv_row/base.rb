# frozen_string_literal: true

module Trainees
  module CreateFromCsvRow
    class Base
      include ServicePattern
      include HasDiversityAttributes
      include HasCourseAttributes

      class Error < StandardError; end

      TRAINING_ROUTES = {
        "Assessment only" => TRAINING_ROUTE_ENUMS[:assessment_only],
        "Early years assessment only" => TRAINING_ROUTE_ENUMS[:early_years_assessment_only],
        "Early years graduate entry" => TRAINING_ROUTE_ENUMS[:early_years_postgrad],
        "Early years graduate employment based" => TRAINING_ROUTE_ENUMS[:early_years_salaried],
        "Early years undergraduate" => TRAINING_ROUTE_ENUMS[:early_years_undergrad],
        "Opt-in (undergrad)" => TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
        "Provider-led (postgrad)" => TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        "Provider-led (undergrad)" => TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
        "School direct (fee funded)" => TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
        "School direct (salaried)" => TRAINING_ROUTE_ENUMS[:school_direct_salaried],
        "Teaching apprenticeship (postgrad)" => TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
      }.freeze

      INITIATIVES = {
        "Now Teach" => ROUTE_INITIATIVES_ENUMS[:now_teach],
        "Not on a training initiative" => ROUTE_INITIATIVES_ENUMS[:no_initiative],
      }.freeze

      def initialize(provider:, csv_row:)
        @csv_row = csv_row
        @provider = provider
        @trainee = @provider.trainees.find_or_initialize_by(provider_trainee_id: lookup("Provider trainee ID"))
      end

      def call
        before_actions
        if trainee.save!
          after_actions
          trainee.save!
        end
      end

    private

      attr_reader :csv_row, :trainee, :provider

      def before_actions
        trainee.assign_attributes(mapped_attributes)
        Trainees::SetAcademicCycles.call(trainee:)
      end

      def after_actions
        sanitise_funding!
        create_degrees!
        validate_and_set_progress!
      end

      def mapped_attributes
        default_attributes
      end

      def default_attributes
        {
          record_source: Trainee::MANUAL_SOURCE,
          region: lookup("Region"),
          training_route: training_route,
          first_names: first_names,
          middle_names: middle_names,
          last_name: last_name,
          sex: sex,
          date_of_birth: Date.parse(lookup("Date of birth")),
          nationality_ids: nationality_ids,
          email: lookup("Email"),
          training_initiative: training_initiative,
          employing_school_id: employing_school_id,
          training_partner_id: training_partner_id,
        }.merge(ethnicity_and_disability_attributes)
         .merge(course_attributes)
         .merge(funding_attributes)
      end

      def create_degrees!
        ::Degrees::CreateFromCsvRow.call(
          trainee: trainee,
          csv_row: csv_row.to_hash.compact.select { |column_name, _| column_name.start_with?("Degree") },
        )
      end

      def ethnic_background
        ::Hesa::CodeSets::Ethnicities::NAME_MAPPING[ethnicity_split&.first]
      end

      def additional_ethnic_background
        ethnicity_split&.last
      end

      def ethnicity_split
        lookup("Ethnicity")&.split(":")&.map(&:strip)
      end

      def ethnicity_attributes
        if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
          ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

          return {
            ethnic_group:,
            ethnic_background:,
            additional_ethnic_background:,
          }
        end

        {
          ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
          ethnic_background: Diversities::NOT_PROVIDED,
        }
      end

      def disabilities
        @disabilities ||=
          if lookup("Disabilities").nil?
            []
          elsif lookup("Disabilities").start_with?("#{Diversities::OTHER}:")
            handle_other_disability
          else
            parse_standard_disabilities
          end
      end

      def handle_other_disability
        other_disability = lookup("Disabilities").split(":", 2).last.strip
        [[Diversities::OTHER, other_disability]]
      end

      def parse_standard_disabilities
        lookup("Disabilities").split(",").map(&:strip)
          .map { |disability| ::Hesa::CodeSets::Disabilities::NAME_MAPPING[disability] }
          .compact
      end

      def disability_attributes
        return { disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] } unless disability_disclosed?
        return { disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] } if disabilities == [Diversities::NO_KNOWN_DISABILITY]

        {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
          trainee_disabilities_attributes: build_disabilities_hash,
        }
      end

      def build_disabilities_hash
        disabilities.each_with_index.map do |disability, index|
          if other_disability?(disability)
            build_other_disability_hash(disability, index)
          else
            build_standard_disability_hash(disability, index)
          end
        end.compact.reduce({}, :merge)
      end

      def other_disability?(disability)
        disability.is_a?(Array) && disability.first == Diversities::OTHER
      end

      def build_other_disability_hash(disability, index)
        other_disability = Disability.find_by(name: Diversities::OTHER)
        {
          index.to_s => {
            disability_id: other_disability.id,
            additional_disability: disability.last,
          },
        }
      end

      def build_standard_disability_hash(disability, index)
        standard_disability = Disability.find_by(name: disability)
        return nil unless standard_disability

        {
          index.to_s => { disability_id: standard_disability.id },
        }
      end

      def first_names
        lookup("First names")
      end

      def middle_names
        lookup("Middle names")
      end

      def last_name
        lookup("Last names")
      end

      def itt_start_date
        lookup("Course ITT start date", "ITT Start Date")
      end

      def itt_end_date
        lookup("Course Expected End Date", "Course ITT End Date", "ITT End Date")
      end

      def trainee_start_date
        lookup("Trainee start date")
      end

      def training_route
        TRAINING_ROUTE_ENUMS[:hpitt_postgrad]
      end

      def training_initiative
        ROUTE_INITIATIVES_ENUMS[:no_initiative]
      end

      def funding_attributes
        return {} if hpitt_trainee?

        funding_type = lookup("Funding: Type")

        {
          applying_for_bursary: funding_type == "bursary",
          applying_for_scholarship: funding_type == "scholarship",
          applying_for_grant: funding_type == "grant",
        }
      end

      def sex
        if lookup("Sex") == Diversities::NOT_PROVIDED
          "sex_not_provided"
        else
          lookup("Sex").downcase
        end
      end

      def nationality_ids
        nationalities.map { |nationality| Nationality.find_by!(name: nationality.downcase.strip) }.map(&:id)
      end

      def nationalities
        return [] if lookup("Nationality").downcase == "other"

        british_nationalities = /english|scottish|welsh|irish/i
        lookup("Nationality").gsub(british_nationalities, "british").split(",").compact
      end

      def course_education_phase
        normalize(lookup("Course education phase"))
      end

      def course_subject_one
        course_subject_name("Course ITT subject 1", "Course ITT subject one")
      end

      def course_subject_two
        course_subject_name("Course ITT subject 2", "Course ITT subject two")
      end

      def course_subject_three
        course_subject_name("Course ITT Subject 3", "Course ITT subject three")
      end

      def course_subject_name(*fields)
        course_subject = lookup(*fields)
        return if course_subject.blank?

        subject_specialism = SubjectSpecialism.where("lower(name) = ?", course_subject.downcase).first

        if subject_specialism.present?
          subject_specialism.name
        else
          raise(Error, "Course subject not recognised: #{course_subject}")
        end
      end

      def course_age_range
        age_range = lookup("Course age range").split(" to ").map(&:to_i)

        if valid_age_ranges.include?(age_range)
          age_range
        else
          raise(Error, "Course age range not recognised: #{age_range}")
        end
      end

      def valid_age_ranges
        Set.new.tap do |set|
          DfE::ReferenceData::AgeRanges.constants.each do |constant|
            set.add(DfE::ReferenceData::AgeRanges.const_get(constant))
          end
        end
      end

      def study_mode
        normalize(lookup("Course study mode", "study mode"))
      end

      def employing_school_id
        School.find_by(urn: lookup("Employing school URN", "Employing school URN or UKPRN"))&.id
      end

      def training_partner_id
        TrainingPartner.find_by_ukprn_or_urn(
          lookup("Lead Partner URN", "Lead Partner URN or UKPRN")&.strip,
        )&.id
      end

      def course_uuid
        course_code = lookup("Publish Course Code")
        return if course_code.blank?

        recruitement_cycle_year = trainee.start_academic_cycle.start_year
        course = provider.courses.find_by(
          code: course_code,
          route: training_route,
          recruitment_cycle_year: recruitement_cycle_year,
        )

        if course.nil?
          raise(Error, "Course not recognised for provider (code: #{course_code}, route: #{training_route}, recruitment cycle year: #{recruitement_cycle_year})")
        end

        course.uuid
      end

      def hpitt_trainee?
        @provider.code == "1TF"
      end

      def sanitise_funding!
        funding_manager = FundingManager.new(trainee)
        trainee.applying_for_bursary = nil unless funding_manager.can_apply_for_bursary?
        trainee.applying_for_grant = nil unless funding_manager.can_apply_for_grant?
        trainee.applying_for_scholarship = nil unless funding_manager.can_apply_for_scholarship?
      end

      def validate_and_set_progress!
        Submissions::TrnValidator.new(trainee:).validators.each do |section, validator|
          section_valid = validator[:form].constantize.new(trainee).valid?
          trainee.progress.public_send("#{section}=", section_valid)
        end
      end

      def case_insensitive_lookup(hash, key)
        return if key.blank?

        # Transform the key and hash keys to lowercase
        hash.transform_keys(&:downcase)[key.strip.downcase]
      end

      def lookup(*column_names)
        csv_hash = csv_row.to_hash

        column_names.each do |column_name|
          normalized_column = normalize(column_name)
          csv_hash.each_key do |key|
            return csv_hash[key] if normalize(key) == normalized_column
          end
        end
        nil
      end

      def normalize(str)
        return if str.blank?

        str.to_s.downcase.strip.gsub(/\s+/, "_").gsub("-", "_").singularize
      end
    end
  end
end
