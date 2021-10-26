# frozen_string_literal: true

class UpdateTraineesWithMissingAgeRanges < ActiveRecord::Migration[6.1]
  MISSING_AGE_RANGES = [
    AgeRange::TWO_TO_SEVEN,
    AgeRange::TWO_TO_ELEVEN,
    AgeRange::TWO_TO_NINETEEN,
    AgeRange::THREE_TO_SIXTEEN,
    AgeRange::FOUR_TO_ELEVEN,
    AgeRange::FOUR_TO_NINETEEN,
    AgeRange::FIVE_TO_EIGHTEEN,
    AgeRange::SEVEN_TO_EIGHTEEN,
    AgeRange::NINE_TO_THIRTEEN,
    AgeRange::ELEVEN_TO_EIGHTEEN,
    AgeRange::THIRTEEN_TO_EIGHTEEN,
    AgeRange::FOURTEEN_TO_EIGHTEEN,
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
