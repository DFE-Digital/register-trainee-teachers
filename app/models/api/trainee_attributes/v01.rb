# frozen_string_literal: true

module Api
  module TraineeAttributes
    class V01
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations::Callbacks

      before_validation :set_course_allocation_subject
      after_validation :set_progress

      ATTRIBUTES = %i[
        first_names
        middle_names
        last_name
        date_of_birth
        email
        course_education_phase
        course_min_age
        course_max_age
        trainee_start_date
        sex
        trn
        training_route
        itt_start_date
        itt_end_date
        diversity_disclosure
        ethnic_group
        ethnic_background
        disability_disclosure
        course_subject_one
        course_subject_two
        course_subject_three
        course_allocation_subject
        study_mode
        application_choice_id
        progress
      ].freeze

      REQUIRED_ATTRIBUTES = %i[
        first_names
        last_name
        date_of_birth
        email
        sex
        training_route
        itt_start_date
        itt_end_date
        diversity_disclosure
        course_subject_one
        study_mode
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      attribute :placements_attributes, array: true, default: -> { [] }
      attribute :degrees_attributes, array: true, default: -> { [] }
      attribute :nationalisations_attributes, array: true, default: -> { [] }
      attribute :date_of_birth, :date
      attribute :record_source, default: -> { RecordSources::API }

      validates(*REQUIRED_ATTRIBUTES, presence: true)

      def initialize(attributes = {})
        super(attributes.except(:placements_attributes, :degrees_attributes, :nationalisations_attributes))

        attributes[:placements_attributes]&.each do |placement_params|
          placements_attributes << Api::PlacementAttributes::V01.new(placement_params)
        end

        attributes[:degrees_attributes]&.each do |degree_params|
          degrees_attributes << DegreeAttributes::V01.new(degree_params)
        end

        attributes[:nationalisations_attributes]&.each do |nationalisation_params|
          nationalisations_attributes << NationalityAttributes::V01.new(nationalisation_params)
        end
      end

      def self.from_trainee(trainee)
        new(trainee.attributes.select { |k, _v| Api::TraineeAttributes::V01::ATTRIBUTES.include?(k.to_sym) })
      end

      def deep_attributes
        attributes.transform_values do |value|
          if value.is_a?(Array)
            value.map { |item| item.respond_to?(:attributes) ? item.attributes : item }
          elsif value.respond_to?(:attributes)
            value.attributes
          else
            value
          end
        end
      end

    private

      def set_course_allocation_subject
        self.course_allocation_subject ||=
          SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject
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
