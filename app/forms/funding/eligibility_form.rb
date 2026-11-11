# frozen_string_literal: true

module Funding
  class EligibilityForm < TraineeForm
    include HesaFundingMethodSync

    FIELDS = %i[
      funding_eligibility
      custom_applying_for_grant
    ].freeze

    # Not a column on Trainee - it maps to applying_for_grant.
    NON_TRAINEE_FIELDS = %i[custom_applying_for_grant].freeze

    attr_accessor(*FIELDS)

    validates :funding_eligibility,
              presence: true,
              inclusion: { in: FUNDING_ELIGIBILITIES.values }

    # For early years postgraduate trainees the grant question is answered here,
    # on the eligibility screen, rather than on the downstream bursary screen.
    validates :custom_applying_for_grant,
              inclusion: { in: %w[yes no] },
              if: :grant_question?

    # Drives validation and persistence of the grant answer. The question is
    # always *shown* for the training bursary state (see the view), but it is
    # only required and saved when a grant genuinely exists for the trainee.
    def grant_question?
      eligible_answer? &&
        funding_manager.eligibility_content_key == :training_bursary &&
        funding_manager.can_apply_for_grant?
    end

    def save!
      if valid?
        assign_attributes_to_trainee

        if FundingManager.new(trainee).eligible_for_funding?
          apply_grant_answer
        else
          clear_funding_method_fields
        end

        Trainees::Update.call(trainee:, update_trs:)
        clear_stash
      else
        false
      end
    end

  private

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee, funding_eligibility:)
    end

    def eligible_answer?
      funding_eligibility != FUNDING_ELIGIBILITIES[:not_eligible]
    end

    def apply_grant_answer
      return unless grant_question?

      trainee.applying_for_grant = custom_applying_for_grant == "yes"
      sync_hesa_funding_method
    end

    def clear_funding_method_fields
      trainee.applying_for_bursary = nil
      trainee.applying_for_scholarship = nil
      trainee.applying_for_grant = nil
      trainee.bursary_tier = nil
      sync_hesa_funding_method
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(:funding_eligibility).merge(
        custom_applying_for_grant: grant_to_custom_value(trainee.applying_for_grant),
      ).merge(new_attributes)
    end

    def grant_to_custom_value(applying_for_grant)
      return if applying_for_grant.nil?

      applying_for_grant ? "yes" : "no"
    end

    def fields_to_ignore_before_save
      NON_TRAINEE_FIELDS
    end

    def form_store_key
      :funding_eligibility
    end
  end
end
