# frozen_string_literal: true

module Schools
  # A change to the employing school means the funding is checked again
  # (Funding::RecheckAfterChange).
  module RechecksFunding
    EMPLOYING_SCHOOL_ATTRIBUTES = %w[
      employing_school_id
      employing_school_not_applicable
      employing_school_name
      employing_school_urn
      employing_school_postcode
    ].freeze

    def save!
      return super unless valid?

      assign_attributes_to_trainee
      changed = trainee.changed.intersect?(EMPLOYING_SCHOOL_ATTRIBUTES)

      super.tap do
        Funding::RecheckAfterChange.call(trainee: trainee, changed: :employing_school) if changed
      end
    end
  end
end
