# frozen_string_literal: true

class BackfillApplicationChoiceId
  include ServicePattern

  attr_reader :trainee

  def initialize(trainee:)
    @trainee = trainee
  end

  def call
    return if trainee.application_choice_id.present?

    if trainee.hesa_record?
      backfill_from_hesa(trainee:)
    elsif trainee.apply_application?
      backfill_from_apply(trainee:)
    end
  end

private

  def backfill_from_hesa(trainee:)
    application_choice_id = trainee.hesa_students.last&.application_choice_id
    trainee.update!(application_choice_id:) if application_choice_id
  end

  def backfill_from_apply(trainee:)
    application_choice_id = trainee.apply_application&.apply_id
    trainee.update!(application_choice_id:) if application_choice_id
  end
end
