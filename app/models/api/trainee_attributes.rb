# frozen_string_literal: true

module Api
  class TraineeAttributes
    include ActiveModel::Model
    include ActiveModel::Attributes
    include DateOfBirthValidatable

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

    attr_accessor(*ATTRIBUTES)

    attribute :placements, array: PlacementAttributes
    attribute :degrees, array: DegreeAttributes

    validates(*ATTRIBUTES, presence: true)
    validates :first_names, :last_name, length: { maximum: 50 }
    validates :middle_names, length: { maximum: 50 }, allow_nil: true
    validates :sex, inclusion: { in: Trainee.sexes.keys }

    def placements_attributes=(attributes)
      @placements = attributes.map do |placement_attributes|
        PlacementAttributes.new(placement_attributes)
      end
    end

    def degrees_attributes=(attributes)
      @degrees = attributes.map do |degree_attributes|
        DegreeAttributes.new(degree_attributes)
      end
    end
  end
end
