# frozen_string_literal: true

# This service is used to find all draft trainees that do not have any valid data for their forms and are considered to be empty.
class FindEmptyTrainees
  include ServicePattern

  EXCLUDED_FIELDS = %w[
    created_at
    updated_at
    dttp_update_sha
    progress
    slug
    training_route
    id
    provider_id
    ebacc
  ].freeze

  class FieldsDoNotExistError < StandardError; end

  attr_reader :trainees, :ids_only, :forms

  def initialize(trainees: Trainee.all, ids_only: false)
    raise FieldsDoNotExistError unless exluded_fields_exist?

    @trainees = trainees
    @ids_only = ids_only
  end

  def call
    draft_trainees.filter_map do |trainee|
      if no_form_data_for?(trainee)
        ids_only ? trainee.id : trainee
      end
    end
  end

private

  def exluded_fields_exist?
    EXCLUDED_FIELDS.all? do |field|
      Trainee.column_names.include?(field)
    end
  end

  def draft_trainees
    # Finds all the draft trainees that do not have any degrees, disabilities and nationalities.
    trainees
      .draft
      .includes(:degrees, :disabilities, :nationalities)
      .where(degrees: { id: nil }, disabilities: { id: nil }, nationalities: { id: nil })
  end

  def no_form_data_for?(trainee)
    # Build a digest of the trainee's current form data, excluding non form related fields
    trainee_values = trainee.serializable_hash.reject { |k, _v| EXCLUDED_FIELDS.include?(k) }.values.compact.join(",")

    trainee.early_years_route? ? check_for_early_years_initial_data(trainee_values) : check_for_initial_draft_data(trainee_values)
  end

  def check_for_initial_draft_data(values)
    # If the trainee has form related fields set, the value digest will be a long string containing all the current values
    # otherwise we just expect it to match the state field, which would just be the value "draft"
    values == "draft"
  end

  def check_for_early_years_initial_data(values)
    # For an early years trainee, we expect the values to just match the initial data set when the route is selected otherwise
    # it would have additional form data set.
    min_age = AgeRange::ZERO_TO_FIVE.first
    max_age = AgeRange::ZERO_TO_FIVE.last

    values == "#{CourseSubjects::EARLY_YEARS_TEACHING},draft,#{min_age},#{max_age}"
  end
end
