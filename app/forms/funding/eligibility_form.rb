# frozen_string_literal: true

module Funding
  class EligibilityForm < TraineeForm
    FIELDS = %i[
      funding_eligibility
    ].freeze

    attr_accessor(*FIELDS)

    validates :funding_eligibility,
              presence: true,
              inclusion: { in: FUNDING_ELIGIBILITIES.values }

    def save!
      if valid?
        clear_funding_fields if eligibility_changed?
        assign_attributes_to_trainee
        Trainees::Update.call(trainee:, update_trs:)
        clear_stash
      else
        false
      end
    end

  private

    def eligibility_changed?
      trainee.funding_eligibility != funding_eligibility
    end

    def clear_funding_fields
      trainee.assign_attributes(
        applying_for_bursary: nil,
        applying_for_scholarship: nil,
        applying_for_grant: nil,
        bursary_tier: nil,
      )
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :funding_eligibility
    end
  end
end
