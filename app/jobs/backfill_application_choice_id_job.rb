# frozen_string_literal: true

class BackfillApplicationChoiceIdJob < ApplicationJob
  queue_as :default

  def perform
    academic_cycle = AcademicCycle.for_year(2022)
    Trainee
      .where(start_academic_cycle: academic_cycle)
      .where(application_choice_id: nil).find_each do |trainee|
      backfill(trainee:)
    end
  end

private

  def backfill(trainee:)
    return if trainee.application_choice_id.present?

    if trainee.hesa_record?
      backfill_from_hesa(trainee:)
    elsif trainee.apply_application?
      backfill_from_apply(trainee:)
    end
  end

  def backfill_from_hesa(trainee:)
    application_choice_id = trainee.hesa_students.last&.application_choice_id
    trainee.update!(application_choice_id:) if application_choice_id
  end

  def backfill_from_apply(trainee:)
    application_choice_id = trainee.apply_application&.apply_id
    trainee.update!(application_choice_id:) if application_choice_id
  end
end
