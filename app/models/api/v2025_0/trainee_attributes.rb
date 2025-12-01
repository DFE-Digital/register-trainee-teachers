# frozen_string_literal: true

module Api
  module V20250
    class TraineeAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations::Callbacks
      include Api::ErrorAttributeAdapter

      include TrainingRouteManageable
      include PrimaryCourseSubjects
      include DateValidatable
      include Api::ErrorMessageHelpers

      before_validation :set_course_allocation_subject_id
      after_validation :set_progress

      validate :course_subject_two_valid, if: :require_subject?
      validate :course_subject_three_valid, if: :require_subject?
      validate :itt_end_date_valid

      validates :provider_trainee_id, length: { maximum: 50 }
      validates :application_choice_id, length: { maximum: 7 }

      ATTRIBUTES = {
        first_names: {},
        middle_names: {},
        last_name: {},
        date_of_birth: {},
        email: {},
        course_education_phase: {},
        trainee_start_date: {},
        sex: {},
        training_route: {},
        itt_start_date: {},
        itt_end_date: {},
        diversity_disclosure: {},
        ethnicity: {},
        disability_disclosure: {},
        course_subject_one: {},
        course_subject_two: {},
        course_subject_three: {},
        course_allocation_subject_id: {},
        study_mode: {},
        application_choice_id: {},
        progress: {},
        training_initiative: {},
        hesa_id: {},
        provider_trainee_id: {},
        applying_for_bursary: {},
        applying_for_grant: {},
        applying_for_scholarship: {},
        bursary_tier: {},
        nationality: {},
      }.freeze.each do |name, config|
        attribute(name, config[:type], **config.fetch(:options, {}))
      end

      INTERNAL_ATTRIBUTES = {
        lead_partner_id: {},
        lead_partner_not_applicable: { type: :boolean, options: { default: false } },
        employing_school_id: {},
        employing_school_not_applicable: { type: :boolean, options: { default: false } },
        ethnic_group: { type: :string, options: { default: Diversities::ETHNIC_GROUP_ENUMS[:not_provided] } },
        ethnic_background: { type: :string, options: { default: Diversities::NOT_PROVIDED } },
        course_min_age: {},
        course_max_age: {},
        record_source: { type: :string, options: { default: Trainee::API_SOURCE } },
      }.freeze.each do |name, config|
        attribute(name, config[:type], **config.fetch(:options, {}))
      end

      REQUIRED_ATTRIBUTES = %i[
        first_names
        last_name
        date_of_birth
        sex
        training_route
        itt_start_date
        itt_end_date
        diversity_disclosure
        course_subject_one
        study_mode
        hesa_id
      ].freeze

      PROVIDER_LED_POSTGRAD_START_YEAR = 2022

      private_constant :PROVIDER_LED_POSTGRAD_START_YEAR

      attribute :placements_attributes, array: true, default: -> { [] }
      attribute :degrees_attributes, array: true, default: -> { [] }
      attribute :nationalisations_attributes, array: true, default: -> { [] }
      attribute :hesa_trainee_detail_attributes, array: false, default: -> {}
      attribute :trainee_disabilities_attributes, array: true, default: -> { [] }

      validates(*REQUIRED_ATTRIBUTES, presence: true)
      validates :email, presence: true, length: { maximum: 255 }
      validate { |record| EmailFormatValidator.new(record).validate }
      validate :validate_itt_start_and_end_dates
      validate :validate_trainee_start_date
      validate :validate_date_of_birth, if: -> { date_of_birth.present? }
      validate :validate_degrees_presence, if: -> { training_route.present? && requires_degree? }
      validate :validate_degrees_duplicates, if: :duplicate_degrees?
      validate :validate_hesa_id_length, if: -> { hesa_id.present? }

      validates :ethnicity, api_inclusion: {
        in: Hesa::CodeSets::Ethnicities::MAPPING.values.uniq,
        valid_values: Hesa::CodeSets::Ethnicities::MAPPING.keys,
      }, allow_blank: true

      validates :sex, api_inclusion: {
        in: Hesa::CodeSets::Sexes::MAPPING.values,
        valid_values: Hesa::CodeSets::Sexes::MAPPING.keys,
      }, allow_blank: true

      validates :first_names, length: { maximum: 60 }
      validates :last_name, length: { maximum: 60 }
      validates :middle_names, length: { maximum: 60 }, allow_nil: true

      validates :placements_attributes, :degrees_attributes, :nationalisations_attributes, :hesa_trainee_detail_attributes, nested_attributes: true
      validates(
        :training_route,
        inclusion: {
          in: :valid_training_routes,
          message: ->(_, data) { hesa_code_inclusion_message(value: data[:value], valid_values: ReferenceData::TRAINING_ROUTES.hesa_codes) },
        },
        allow_blank: true,
        if: :valid_trainee_start_date?,
      )
      validates :course_subject_one, :course_subject_two, :course_subject_three, api_inclusion: {
        in: ::Hesa::CodeSets::CourseSubjects::MAPPING.values,
        valid_values: Hesa::CodeSets::CourseSubjects::MAPPING.keys,
      }, allow_blank: true

      validates :study_mode, api_inclusion: {
        in: ReferenceData::TRAINEE_STUDY_MODES.names,
        valid_values: ReferenceData::TRAINEE_STUDY_MODES.hesa_codes,
      }, allow_blank: true

      validates :nationality, api_inclusion: {
        in: RecruitsApi::CodeSets::Nationalities::MAPPING.values,
        valid_values: RecruitsApi::CodeSets::Nationalities::MAPPING.keys,
      }, allow_blank: true

      validates :training_initiative, api_inclusion: {
        in: ROUTE_INITIATIVES.keys,
        valid_values: Hesa::CodeSets::TrainingInitiatives::MAPPING.keys,
      }, allow_blank: true

      validates :trainee_disabilities_attributes, uniqueness: true

      validate :validate_lead_partner, unless: :lead_partner_not_applicable
      validate :validate_employing_school, unless: :employing_school_not_applicable

      def initialize(new_attributes = {})
        new_attributes = new_attributes.to_h.with_indifferent_access

        super(
          new_attributes.slice(
            *(ATTRIBUTES.keys + INTERNAL_ATTRIBUTES.keys),
          )
        )

        build_nested_models(new_attributes)
      end

      def build_nested_models(new_attributes)
        new_attributes[:placements_attributes]&.each do |placement_params|
          placements_attributes << PlacementAttributes.new(placement_params, record_source:)
        end

        new_attributes[:degrees_attributes]&.each do |degree_params|
          degrees_attributes << DegreeAttributes.new(degree_params, record_source:)
        end

        new_attributes[:nationalisations_attributes]&.each do |nationalisation_params|
          nationalisations_attributes << NationalityAttributes.new(nationalisation_params)
        end

        new_hesa_trainee_detail_attributes = new_attributes.slice(*HesaTraineeDetailAttributes::ATTRIBUTES)

        if new_hesa_trainee_detail_attributes.present?
          self.hesa_trainee_detail_attributes = V20250::HesaTraineeDetailAttributes.new(
            new_hesa_trainee_detail_attributes.merge(trainee_attributes: self),
            record_source:,
          )
        end

        self.trainee_disabilities_attributes = []

        new_attributes[:disabilities]&.each do |disability|
          trainee_disabilities_attributes << { disability_id: disability.id }
        end
      end

      def assign_attributes(new_attributes)
        super(
          new_attributes.slice(
            *(ATTRIBUTES.keys + INTERNAL_ATTRIBUTES.keys),
          )
        )

        self.nationalisations_attributes = []

        new_attributes[:nationalisations_attributes]&.each do |nationalisation_params|
          nationalisations_attributes << NationalityAttributes.new(nationalisation_params)
        end

        update_hesa_trainee_detail_attributes(new_attributes)

        self.trainee_disabilities_attributes = []

        new_attributes[:disabilities]&.each do |disability|
          next if disability.blank?

          trainee_disabilities_attributes << { disability_id: disability.id }
        end

        if primary_education_phase? && !new_attributes.values.include?(HesaMapperConstants::INVALID) && primary_education_phase?
          self.attributes = primary_course_subjects
        end
      end

      def update_hesa_trainee_detail_attributes(new_attributes)
        new_hesa_attributes = new_attributes.slice(*HesaTraineeDetailAttributes::ATTRIBUTES)
        return if new_hesa_attributes.blank?

        updated_hesa_attributes = hesa_trainee_detail_attributes ||
          V20250::HesaTraineeDetailAttributes.new({ trainee_attributes: self })

        updated_hesa_attributes.assign_attributes(new_hesa_attributes)

        updated_hesa_attributes
      end

      def self.params_with_updated_disabilities(new_trainee_attributes, params_for_update)
        updated_hesa_disabilities = update_hesa_disabilities(
          new_trainee_attributes.hesa_trainee_detail_attributes&.hesa_disabilities || {},
          params_for_update,
        )

        updated_disabilities = updated_hesa_disabilities.map do |_key, value|
          Disability.find_by(name: ::Hesa::CodeSets::Disabilities::MAPPING[value])
        end

        params_for_update.merge(hesa_disabilities: updated_hesa_disabilities, disabilities: updated_disabilities)
      end

      def self.update_hesa_disabilities(original_hesa_disabilities, params_for_update)
        updated_hesa_disabilities = original_hesa_disabilities
        updated_hesa_disabilities = updated_hesa_disabilities.merge(params_for_update[:hesa_disabilities]) if params_for_update[:hesa_disabilities].present?

        updated_hesa_disabilities
      end

      def self.from_trainee(trainee, params_for_update)
        trainee_attributes = trainee.attributes.select { |k, _v|
          ATTRIBUTES.include?(k.to_sym) || INTERNAL_ATTRIBUTES.include?(k.to_sym)
        }

        hesa_trainee_detail_attributes = trainee.hesa_trainee_detail&.attributes&.select { |k, _v|
          HesaTraineeDetailAttributes::ATTRIBUTES.include?(k.to_sym)
        } || {}

        degrees_attributes = trainee.degrees.map do |degree|
          degree.attributes.select { |k, _v| DegreeAttributes::ATTRIBUTES.include?(k.to_sym) }
        end || []

        trainee_attributes = trainee_attributes.merge(
          hesa_trainee_detail_attributes,
          degrees_attributes:,
        )

        trainee_attributes["sex"] = Trainee.sexes[trainee.sex]

        new_trainee_attributes = new(trainee_attributes)

        params_with_updated_disabilities = params_with_updated_disabilities(new_trainee_attributes, params_for_update)

        new_trainee_attributes.assign_attributes(params_with_updated_disabilities)

        new_trainee_attributes
      end

      def deep_attributes
        deep_attributes = attributes.except("ethnicity", "nationality").transform_values do |value|
          if value.is_a?(Array)
            value.map { |item| item.respond_to?(:attributes) ? item.attributes : item }
          elsif value.respond_to?(:attributes)
            value.attributes
          else
            value
          end
        end

        deep_attributes.delete("hesa_trainee_detail_attributes") if deep_attributes["hesa_trainee_detail_attributes"].blank?

        deep_attributes
      end

      delegate :count, to: :errors, prefix: true

      def all_errors
        errors
      end

    private

      def valid_training_routes
        ReferenceData::TRAINING_ROUTES.hesa_codes(year: start_year)
        # if start_year.present? && start_year.to_i < PROVIDER_LED_POSTGRAD_START_YEAR
        #   ReferenceData::TRAINING_ROUTES.names_with_hesa_codes.excluding(ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name)
        # else
        #   ReferenceData::TRAINING_ROUTES.names_with_hesa_codes
        # end
      end

      def start_year
        start_date = trainee_start_date.presence || itt_start_date.presence
        return nil if start_date.blank?

        AcademicCycle.for_date(start_date)&.start_year
      end

      def valid_trainee_start_date?
        errors[:trainee_start_date].blank?
      end

      def validate_date_of_birth
        return errors.add(:date_of_birth, :invalid) unless valid_date_string?(date_of_birth)

        parsed_date_of_birth = date_of_birth.is_a?(String) ? Date.iso8601(date_of_birth) : date_of_birth

        if parsed_date_of_birth < 100.years.ago
          errors.add(:date_of_birth, :invalid)
        elsif parsed_date_of_birth > Time.zone.today
          errors.add(:date_of_birth, :future)
        elsif parsed_date_of_birth > 16.years.ago
          errors.add(:date_of_birth, :under16)
        end
      end

      def validate_trainee_start_date
        self.trainee_start_date = itt_start_date if trainee_start_date.blank?

        return if trainee_start_date.blank?

        if !valid_date_string?(trainee_start_date)
          errors.add(:trainee_start_date, :invalid)
          return
        end

        start_date = trainee_start_date.is_a?(String) ? Date.parse(trainee_start_date) : trainee_start_date
        if start_date < 10.years.ago
          errors.add(:trainee_start_date, :too_old)
        elsif start_date.future? && !trainee_and_itt_start_dates_match?
          errors.add(:trainee_start_date, :future)
        end
      end

      def trainee_and_itt_start_dates_match?
        parsed_trainee_start_date = trainee_start_date.is_a?(String) ? Date.parse(trainee_start_date) : trainee_start_date
        parsed_itt_start_date = itt_start_date.is_a?(String) ? Date.parse(itt_start_date) : itt_start_date

        parsed_trainee_start_date.present? &&
          parsed_itt_start_date.present? &&
          parsed_trainee_start_date == parsed_itt_start_date
      end

      def validate_degrees_presence
        errors.add(:degrees_attributes, :blank) if degrees_attributes.empty?
      end

      def validate_degrees_duplicates
        errors.add(:degrees_attributes, :duplicate)
      end

      def duplicate_degrees?
        degrees_attributes.group_by(&:attributes_for_duplicates).any? do |key, group|
          key.present? && group.size > 1
        end
      end

      def set_course_allocation_subject_id
        return course_subject_one if course_subject_one.is_a?(Api::V20250::HesaMapper::Attributes::InvalidValue)

        self.course_allocation_subject_id ||=
          SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject&.id
      end

      def set_progress
        if errors.blank?
          self.progress ||= {}
          progress[:personal_details] = true
          progress[:contact_details] = true
          progress[:diversity] = true
          progress[:course_details] = true
          progress[:training_details] = true
          progress[:trainee_start_status] = true
          progress[:trainee_data] = true
          progress[:schools] = true
          progress[:funding] = true
          progress[:iqts_country] = true
        end
      end

      def require_subject?
        EARLY_YEARS_TRAINING_ROUTES.exclude?(training_route)
      end

      def course_subject_two_valid
        return if course_subject_two.nil?

        errors.add(:course_subject_two, :duplicate) if course_subject_one == course_subject_two
      end

      def course_subject_three_valid
        return if course_subject_three.nil?

        errors.add(:course_subject_three, :duplicate) if [course_subject_one, course_subject_two].include?(course_subject_three)
      end

      def itt_end_date_valid
        return if !valid_date_string?(itt_start_date) || !valid_date_string?(itt_end_date)

        parsed_itt_start_date = itt_start_date.is_a?(String) ? Date.iso8601(itt_start_date) : itt_start_date
        parsed_itt_end_date   = itt_end_date.is_a?(String) ? Date.iso8601(itt_end_date) : itt_end_date

        errors.add(:itt_end_date, :before_or_same_as_start_date) if parsed_itt_start_date >= parsed_itt_end_date
      end

      def validate_itt_start_and_end_dates
        if itt_start_date.present? && !valid_date_string?(itt_start_date)
          errors.add(:itt_start_date, :invalid)
        elsif itt_start_date.present?
          start_date = itt_start_date.is_a?(String) ? Date.parse(itt_start_date) : itt_start_date
          if start_date.year > next_year
            errors.add(:itt_start_date, :future)
          end
        end

        if itt_end_date.present? && !valid_date_string?(itt_end_date)
          errors.add(:itt_end_date, :invalid)
        end
      end

      def validate_hesa_id_length
        errors.add(:hesa_id, :length) unless hesa_id.length.in?([13, 17])
      end

      def next_year
        Time.zone.now.year.next
      end

      def validate_lead_partner
        if lead_partner_id.is_a?(Api::V20250::HesaMapper::Attributes::InvalidValue)
          errors.add(:lead_partner_id, :invalid, value: lead_partner_id.to_s)
        end
      end

      def validate_employing_school
        if employing_school_id.is_a?(Api::V20250::HesaMapper::Attributes::InvalidValue)
          errors.add(:employing_school_id, :invalid, value: employing_school_id.to_s)
        end
      end
    end
  end
end
