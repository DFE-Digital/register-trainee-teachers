# frozen_string_literal: true

# Whether an Early years teacher degree apprenticeship trainee holds a level 5 qualification.
class LevelFiveDeclarationForm < TraineeForm
  FIELDS = %i[level_five_qualification].freeze

  attr_accessor(*FIELDS)

  validates :level_five_qualification, inclusion: { in: [true, false] }

  # The radios send "true" or "false".
  def level_five_qualification=(value)
    @level_five_qualification = ActiveModel::Type::Boolean.new.cast(value)
  end

  # The answer sets the course length, so it can fill in the expected end date.
  # A changed answer sends the course details back to be confirmed and resets the funding.
  def save!
    return false unless valid?

    previous_answer = trainee.level_five_qualification
    funding_started_before = Trainees::RecheckAfterLevelFiveChange.funding_started?(trainee)
    super.tap do
      Trainees::SetLevelFiveEndDate.call(trainee:, previous_answer:)
      Trainees::RecheckAfterLevelFiveChange.call(trainee:, previous_answer:, funding_started_before:)
    end
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end
end
