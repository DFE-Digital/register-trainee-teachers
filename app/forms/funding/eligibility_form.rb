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
        assign_attributes_to_trainee
        clear_funding_method_fields unless FundingManager.new(trainee).eligible_for_funding?
        Trainees::Update.call(trainee:, update_trs:)
        clear_stash
      else
        false
      end
    end

  private

    def clear_funding_method_fields
      trainee.applying_for_bursary = nil
      trainee.applying_for_scholarship = nil
      trainee.applying_for_grant = nil
      trainee.bursary_tier = nil
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :funding_eligibility
    end
  end
end
