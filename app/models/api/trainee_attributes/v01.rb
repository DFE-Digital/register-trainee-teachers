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
        middle_names
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

      validates(*REQUIRED_ATTRIBUTES, presence: true)
      validates :first_names, :last_name, length: { maximum: 50 }
      validates :middle_names, length: { maximum: 50 }, allow_nil: true
      validates :sex, inclusion: { in: Trainee.sexes.keys }
      validate :date_of_birth_valid

      def initialize(attributes = {})
        super(attributes.except(:placements_attributes, :degrees_attributes))

        attributes[:placements_attributes]&.each do |placement_params|
          placements_attributes << Api::PlacementAttributes::V01.new(placement_params)
        end

        attributes[:degrees_attributes]&.each do |degree_params|
          degrees_attributes << DegreeAttributes::V01.new(degree_params)
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

      def date_of_birth_valid
        value = date_of_birth
        if value.is_a?(String)
          value =
            begin
              Date.parse(value)
            rescue StandardError
              nil
            end
        end

        if !value.is_a?(Date)
          errors.add(:date_of_birth, :invalid)
        elsif value > Time.zone.today
          errors.add(:date_of_birth, :future)
        elsif value.year.digits.length != 4
          errors.add(:date_of_birth, :invalid_year)
        elsif value > 16.years.ago
          errors.add(:date_of_birth, :under16)
        elsif value < 100.years.ago
          errors.add(:date_of_birth, :past)
        end
      end

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
