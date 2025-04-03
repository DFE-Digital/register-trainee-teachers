# frozen_string_literal: true

module Api
  module V01
    class TraineeAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations::Callbacks

      include PrimaryCourseSubjects

      before_validation :set_course_allocation_subject_id
      after_validation :set_progress

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
        lead_partner_id: { type: :integer },
        lead_partner_not_applicable: { type: :boolean, options: { default: false } },
        employing_school_id: { type: :integer },
        employing_school_not_applicable: { type: :boolean, options: { default: false } },
        ethnic_group: { type: :string, options: { default: Diversities::ETHNIC_GROUP_ENUMS[:not_provided] } },
        ethnic_background: { type: :string, options: { default: Diversities::NOT_PROVIDED } },
        course_min_age: {},
        course_max_age: {},
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
      attribute :record_source, default: -> { Trainee::API_SOURCE }

      validates(*REQUIRED_ATTRIBUTES, presence: true)
      validates :email, presence: true, length: { maximum: 255 }
      validates :ethnicity, inclusion: Hesa::CodeSets::Ethnicities::MAPPING.values.uniq, allow_blank: true
      validate { |record| EmailFormatValidator.new(record).validate }
      validate :validate_itt_start_and_end_dates
      validate :validate_trainee_start_date
      validate :validate_date_of_birth
      validates :sex, inclusion: Hesa::CodeSets::Sexes::MAPPING.values, allow_blank: true
      validates :placements_attributes, :degrees_attributes, :nationalisations_attributes, :hesa_trainee_detail_attributes, nested_attributes: true
      validates :training_route, inclusion: { in: :valid_training_routes }, allow_blank: true, if: :valid_trainee_start_date?
      validates :course_subject_one, :course_subject_two, :course_subject_three,
                inclusion: { in: ::Hesa::CodeSets::CourseSubjects::MAPPING.values }, allow_blank: true
      validates :study_mode,
                inclusion: { in: TRAINEE_STUDY_MODE_ENUMS.keys }, allow_blank: true
      validates :nationality,
                inclusion: { in: RecruitsApi::CodeSets::Nationalities::MAPPING.values }, allow_blank: true
      validates :training_initiative,
                inclusion: { in: ROUTE_INITIATIVES.keys }, allow_blank: true
      validates :trainee_disabilities_attributes, uniqueness: true

      def initialize(new_attributes = {})
        new_attributes = new_attributes.to_h.with_indifferent_access

        super(
          new_attributes.slice(
            *(ATTRIBUTES.keys + INTERNAL_ATTRIBUTES.keys + %i[record_source nationalities]),
          ).except(
            :placements_attributes,
            :degrees_attributes,
            :nationalisations_attributes,
            :hesa_trainee_detail_attributes,
            :trainee_disabilities_attributes,
          ))

        build_nested_models(new_attributes)

        self.trainee_disabilities_attributes = []
        new_attributes[:disabilities]&.each do |disability|
          trainee_disabilities_attributes << { disability_id: disability.id }
        end
      end

      def build_nested_models(new_attributes)
        new_attributes[:placements_attributes]&.each do |placement_params|
          placements_attributes << PlacementAttributes.new(placement_params)
        end

        new_attributes[:degrees_attributes]&.each do |degree_params|
          degrees_attributes << DegreeAttributes.new(degree_params)
        end

        new_attributes[:nationalisations_attributes]&.each do |nationalisation_params|
          nationalisations_attributes << NationalityAttributes.new(nationalisation_params)
        end

        new_hesa_trainee_detail_attributes = new_attributes.slice(*HesaTraineeDetailAttributes::ATTRIBUTES)
        if new_hesa_trainee_detail_attributes.present?
          self.hesa_trainee_detail_attributes = V01::HesaTraineeDetailAttributes.new(new_hesa_trainee_detail_attributes)
        end

        self.trainee_disabilities_attributes = []

        new_attributes[:disabilities]&.each do |disability|
          trainee_disabilities_attributes << { disability_id: disability.id }
        end
      end

      def assign_attributes(new_attributes)
        super(
          new_attributes.slice(
            *(ATTRIBUTES.keys + INTERNAL_ATTRIBUTES.keys) + %i[record_source nationalities],
          ).except(
            :placements_attributes,
            :degrees_attributes,
            :nationalisations_attributes,
            :hesa_trainee_detail_attributes,
            :trainee_disabilities_attributes,
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

        updated_hesa_attributes = hesa_trainee_detail_attributes || HesaTraineeDetailAttributes.new({})

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

        trainee_attributes = trainee_attributes.merge(hesa_trainee_detail_attributes)
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
        if start_year.present? && start_year.to_i < PROVIDER_LED_POSTGRAD_START_YEAR
          Hesa::CodeSets::TrainingRoutes::MAPPING.values.excluding(TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
        else
          Hesa::CodeSets::TrainingRoutes::MAPPING.values
        end
      end

      def start_year
        AcademicCycle.for_date(trainee_start_date)&.start_year
      end

      def valid_trainee_start_date?
        errors[:trainee_start_date].blank?
      end

      def validate_date_of_birth
        if date_of_birth.present? && !valid_date_string?(date_of_birth)
          errors.add(:date_of_birth, :invalid)
        end
      end

      def validate_trainee_start_date
        return if trainee_start_date.blank?

        if !valid_date_string?(trainee_start_date)
          errors.add(:trainee_start_date, :invalid)
          return
        end

        start_date = trainee_start_date.is_a?(String) ? Date.parse(trainee_start_date) : trainee_start_date
        if start_date < 10.years.ago
          errors.add(:trainee_start_date, :too_old)
        elsif start_date.future?
          errors.add(:trainee_start_date, :future)
        end
      end

      def validate_itt_start_and_end_dates
        if itt_start_date.present? && !valid_date_string?(itt_start_date)
          errors.add(:itt_start_date, :invalid)
        end

        if itt_end_date.present? && !valid_date_string?(itt_end_date)
          errors.add(:itt_end_date, :invalid)
        end
      end

      def valid_date_string?(date)
        DateTime.iso8601(date.to_s)
        true
      rescue StandardError
        false
      end

      def set_course_allocation_subject_id
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
    end
  end
end
