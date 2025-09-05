# frozen_string_literal: true

class AddMissingDisabilitiesFromTadCheck < ActiveRecord::Migration[6.1]
  FILE = "data/tad_disability_check_2022-10-03.csv"

  def up
    return unless csv

    disclosures!
    learning_difficulties!
    other_disabilites!
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  # no need to distinguish - we can just grab all the records from
  # the CSV and update their disclosure enums
  def disclosures!
    Trainee.where(dttp_id: [*learning_difficulty_dttp_ids, *other_disability_dttp_ids]).update_all(
      diversity_disclosure: 0, # diversity_disclosed
      disability_disclosure: 0, # disabled
      updated_at: Time.zone.now,
    )
  end

  def learning_difficulties!
    return if learning_difficulty_trainees.empty?

    TraineeDisability.upsert_all(
      learning_difficulty_trainees.map do |trainee|
        { trainee_id: trainee.id, disability_id: learning_difficulty.id, created_at: Time.zone.now, updated_at: Time.zone.now }
      end,
      unique_by: %i[disability_id trainee_id],
    )
  end

  def other_disabilites!
    return if other_trainees.empty?

    TraineeDisability.upsert_all(
      other_trainees.map do |trainee|
        { trainee_id: trainee.id, disability_id: other_disability.id, created_at: Time.zone.now, updated_at: Time.zone.now }
      end,
      unique_by: %i[disability_id trainee_id],
    )
  end

  def learning_difficulty_dttp_ids
    @learning_difficulty_dttp_ids ||=
      csv.select { |row| row[:disability] == "LEARNING_DIFFICULTY" }.pluck(:dttp_id)
  end

  def learning_difficulty_trainees
    @learning_difficulty_trainees ||= Trainee.where(dttp_id: learning_difficulty_dttp_ids)
  end

  def learning_difficulty
    return @learning_difficulty if defined?(@learning_difficulty)

    @learning_difficulty = Disability.find_by(name: ::Diversities::LEARNING_DIFFICULTY)
  end

  def other_disability_dttp_ids
    @other_disability_dttp_ids ||=
      csv.select { |row| row[:disability] == "OTHER" }.pluck(:dttp_id)
  end

  def other_trainees
    @other_trainees ||= Trainee.where(dttp_id: other_disability_dttp_ids)
  end

  def other_disability
    return @other_disability if defined?(@other_disability)

    @other_disability = Disability.find_by(name: ::Diversities::OTHER)
  end

  def csv
    return unless Rails.root.join(FILE).exist?

    @csv ||= CSV.table(Rails.root.join(FILE))
  end
end
