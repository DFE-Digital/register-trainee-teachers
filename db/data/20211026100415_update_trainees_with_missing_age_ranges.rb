# frozen_string_literal: true

class UpdateTraineesWithMissingAgeRanges < ActiveRecord::Migration[6.1]
  AGE_RANGES = DfE::ReferenceData::AgeRanges
  MISSING_AGE_RANGES = [
    AGE_RANGES::TWO_TO_SEVEN,
    AGE_RANGES::TWO_TO_ELEVEN,
    AGE_RANGES::TWO_TO_NINETEEN,
    AGE_RANGES::THREE_TO_SIXTEEN,
    AGE_RANGES::FOUR_TO_ELEVEN,
    AGE_RANGES::FOUR_TO_NINETEEN,
    AGE_RANGES::FIVE_TO_EIGHTEEN,
    AGE_RANGES::SEVEN_TO_EIGHTEEN,
    AGE_RANGES::NINE_TO_THIRTEEN,
    AGE_RANGES::ELEVEN_TO_EIGHTEEN,
    AGE_RANGES::THIRTEEN_TO_EIGHTEEN,
    AGE_RANGES::FOURTEEN_TO_EIGHTEEN,
  ].freeze

  # Finding all mis-mapped trainees and update them in DTTP. Call the update job
  # directly rather than reset the update SHA since some of these trainees are
  # in states excluded by QueueTraineeUpdatesJob.
  def up
    MISSING_AGE_RANGES.each do |range|
      trainees = Trainee.where(course_min_age: range[0], course_max_age: range[1])
                        .where.not(state: "draft")

      trainees.find_each { |t| Dttp::UpdateTraineeJob.perform_later(t) }
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
