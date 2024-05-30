# frozen_string_literal: true

module Api
  module V01
    class TraineeAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations::Callbacks

      before_validation :set_course_allocation_subject_id
      after_validation :set_progress

      ATTRIBUTES = {
        first_names: {},
        middle_names: {},
        last_name: {},
        date_of_birth: { type: :date },
        email: {},
        course_education_phase: {},
        course_min_age: {},
        course_max_age: {},
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
      }.freeze.each do |name, config|
        attribute(name, config[:type], **config.fetch(:options, {}))
      end

      INTERNAL_ATTRIBUTES = {
        lead_school_id: { type: :integer },
        lead_school_not_applicable: { type: :boolean, options: { default: false } },
        employing_school_id: { type: :integer },
        employing_school_not_applicable: { type: :boolean, options: { default: false } },
        ethnic_group: { type: :string, options: { default: Diversities::ETHNIC_GROUP_ENUMS[:not_provided] } },
        ethnic_background: { type: :string, options: { default: Diversities::NOT_PROVIDED } },
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

      attribute :placements_attributes, array: true, default: -> { [] }
      attribute :degrees_attributes, array: true, default: -> { [] }
      attribute :nationalisations_attributes, array: true, default: -> { [] }
      attribute :hesa_trainee_detail_attributes, array: false, default: -> {}
      attribute :trainee_disabilities_attributes, array: true, default: -> { [] }
      attribute :record_source, default: -> { Trainee::API_SOURCE }

      validates(*REQUIRED_ATTRIBUTES, presence: true)
      validates :email, presence: true, length: { maximum: 255 }
      validates :ethnicity, inclusion: Hesa::CodeSets::Ethnicities::MAPPING.keys, allow_nil: true

      validate do |record|
        EmailFormatValidator.new(record).validate
      end

      validate :validate_itt_start_and_end_dates
      validate :validate_trainee_start_date

      validates(:sex, inclusion: Hesa::CodeSets::Sexes::MAPPING.values, allow_blank: true)

      def initialize(new_attributes = {})
        new_attributes = new_attributes.to_h.with_indifferent_access

        super(
          new_attributes.slice(
            *(ATTRIBUTES.keys + INTERNAL_ATTRIBUTES.keys) + %i[nationalities],
          ).except(
            :placements_attributes,
            :degrees_attributes,
            :nationalisations_attributes,
            :hesa_trainee_detail_attributes,
            :trainee_disabilities_attributes,
          ))

        new_attributes[:placements_attributes]&.each do |placement_params|
          placements_attributes << Api::PlacementAttributes::V01.new(placement_params)
        end

        new_attributes[:degrees_attributes]&.each do |degree_params|
          degrees_attributes << DegreeAttributes::V01.new(degree_params)
        end

        new_attributes[:nationalisations_attributes]&.each do |nationalisation_params|
          nationalisations_attributes << NationalityAttributes::V01.new(nationalisation_params)
        end

        hesa_trainee_detail_attributes_raw = new_attributes.slice(*HesaTraineeDetailAttributes::V01::ATTRIBUTES)

        self.hesa_trainee_detail_attributes =
          HesaTraineeDetailAttributes::V01.new(
            hesa_trainee_detail_attributes_raw,
          )

        self.trainee_disabilities_attributes = []
        new_attributes[:disabilities]&.each do |disability|
          trainee_disabilities_attributes << { disability_id: disability.id }
        end
      end

      def assign_attributes(new_attributes)
        super(
          new_attributes.slice(
            *(ATTRIBUTES.keys + INTERNAL_ATTRIBUTES.keys) + %i[nationalities],
          ).except(
            :placements_attributes,
            :degrees_attributes,
            :nationalisations_attributes,
            :hesa_trainee_detail_attributes,
            :trainee_disabilities_attributes,
          ))

        self.nationalisations_attributes = []
        new_attributes[:nationalisations_attributes]&.each do |nationalisation_params|
          nationalisations_attributes << NationalityAttributes::V01.new(nationalisation_params)
        end

        update_hesa_trainee_detail_attributes(new_attributes)

        self.trainee_disabilities_attributes = []
        new_attributes[:disabilities]&.each do |disability|
          trainee_disabilities_attributes << { disability_id: disability.id }
        end
      end

      def update_hesa_trainee_detail_attributes(attributes)
        new_hesa_attributes = attributes.slice(*HesaTraineeDetailAttributes::V01::ATTRIBUTES)
        return if new_hesa_attributes.blank?

        updated_hesa_attributes = hesa_trainee_detail_attributes || HesaTraineeDetailAttributes::V01.new({})
        updated_hesa_attributes.assign_attributes(new_hesa_attributes)
        updated_hesa_attributes
      end

      def self.from_trainee(trainee)
        trainee_attributes = trainee.attributes.select { |k, _v|
          ATTRIBUTES.include?(k.to_sym) || INTERNAL_ATTRIBUTES.include?(k.to_sym)
        }

        hesa_trainee_detail_attributes = trainee.hesa_trainee_detail&.attributes&.select { |k, _v|
          Api::HesaTraineeDetailAttributes::V01::ATTRIBUTES.include?(k.to_sym)
        } || {}

        trainee_attributes = trainee_attributes.merge(hesa_trainee_detail_attributes)
        trainee_attributes["sex"] = Trainee.sexes[trainee.sex]

        new(trainee_attributes)
      end

      def deep_attributes
        attributes.except("ethnicity").transform_values do |value|
          if value.is_a?(Array)
            value.map { |item| item.respond_to?(:attributes) ? item.attributes : item }
          elsif value.respond_to?(:attributes)
            value.attributes
          else
            value
          end
        end
      end

      delegate :count, to: :errors, prefix: true

      def all_errors
        errors
      end

    private

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
        return true if date.is_a?(Date) || date.is_a?(DateTime)

        begin
          DateTime.parse(date)
          true
        rescue StandardError
          false
        end
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
