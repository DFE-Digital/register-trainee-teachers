# frozen_string_literal: true

module Api
  class TraineeAttributes
    include ActiveModel::Model
    include ActiveModel::Attributes

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
      study_mode
      application_choice_id
    ].freeze

    ATTRIBUTES.each do |attr|
      attribute attr
    end

    attribute :placements_attributes, array: true, default: []
    attribute :degrees_attributes, array: true, default: []

    validates(*ATTRIBUTES, presence: true)
    validates :first_names, :last_name, length: { maximum: 50 }
    validates :middle_names, length: { maximum: 50 }, allow_nil: true
    validates :sex, inclusion: { in: Trainee.sexes.keys }
    validate :date_of_birth_valid

    def initialize(attributes = {})
      super(attributes.except(:placements_attributes, :degrees_attributes))

      attributes[:placements_attributes]&.each do |placement_params|
        placements_attributes << PlacementAttributes.new(placement_params)
      end

      attributes[:degrees_attributes]&.each do |degree_params|
        degrees_attributes << DegreeAttributes.new(degree_params)
      end
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
      value = Date.parse(date_of_birth) rescue nil

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
  end
end
