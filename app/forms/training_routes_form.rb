# frozen_string_literal: true

class TrainingRoutesForm < TraineeForm
  COURSE_CHANGE = "edit-course"

  FIELDS = %i[
    training_route
    context
  ].freeze

  attr_accessor(*FIELDS)

  validates :training_route, presence: true

  delegate :update_training_route!, to: :route_data_manager

  def initialize(...)
    super(...)
    @route_data_manager = RouteDataManager.new(trainee:)
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def course_change?
    context == COURSE_CHANGE
  end

  def save!
    if valid?
      assign_attributes_to_trainee
      update_training_route!(trainee.training_route)
      Trainees::Update.call(trainee:)
      clear_stash
    else
      false
    end
  end

  def fields_to_ignore_before_stash
    [:context]
  end

  def fields_to_ignore_before_save
    [:context]
  end

  attr_reader :route_data_manager
end
