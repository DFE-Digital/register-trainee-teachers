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

    attribute :placements, array: true, default: []
    attribute :degrees, array: true, default: []

    validates(*ATTRIBUTES, presence: true)
    validates :first_names, :last_name, length: { maximum: 50 }
    validates :middle_names, length: { maximum: 50 }, allow_nil: true
    validates :sex, inclusion: { in: Trainee.sexes.keys }
    validate :date_of_birth_valid

    def initialize(attributes = {})
      attributes[:placements_attributes]&.each do |placement_params|
        placements << PlacementAttributes.new(placement_params)
      end

      attributes[:degrees_attributes]&.each do |degree_params|
        degrees << DegreeAttributes.new(degree_params)
      end

      super(attributes.except(:placements_attributes, :degrees_attributes))
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
