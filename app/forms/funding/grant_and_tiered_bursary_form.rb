# frozen_string_literal: true

module Funding
  class GrantAndTieredBursaryForm < TraineeForm
    FIELDS = %i[
      applying_for_bursary
      bursary_tier
      custom_bursary_tier
      applying_for_scholarship
      applying_for_grant
    ].freeze

    NON_TRAINEE_FIELDS = %i[
      custom_bursary_tier
    ].freeze

    FUNDING_TYPES = (Trainee.bursary_tiers.keys + FUNDING_TYPE_ENUMS.values).freeze

    NONE_TYPE = "none"

    attr_accessor(*FIELDS)

    validates :custom_bursary_tier, inclusion: { in: Trainee.bursary_tiers.keys + [NONE_TYPE] }
    validates :applying_for_grant, inclusion: { in: [true, false] }

    delegate :applicable_available_funding, :can_apply_for_scholarship?, :can_apply_for_tiered_bursary?,
             :can_apply_for_grant?, :grant_amount, :bursary_amount,
             :scholarship_amount, :allocation_subject_name,
             :funding_guidance_link_text, :funding_guidance_url,
             to: :funding_manager

    def initialize(trainee, params: {}, user: nil, store: FormStore)
      super(trainee, params:, user:, store:)
    end

  private

    def compute_fields
      fields = trainee.attributes.symbolize_keys.slice(*FIELDS)

      if params[:custom_bursary_tier].present?
        fields[:custom_bursary_tier] = params[:custom_bursary_tier]
      elsif trainee.applying_for_bursary.nil?
        fields[:custom_bursary_tier] = nil
      elsif trainee.applying_for_bursary
        fields[:custom_bursary_tier] = trainee.bursary_tier
      else
        fields[:custom_bursary_tier] = NONE_TYPE
      end
      fields.merge!(new_attributes)
      fields
    end

    def new_attributes
      if params.present?
        fields_from_store.merge(grant_and_tiered_bursary_params).symbolize_keys
      else
        params
      end
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end

    def grant_and_tiered_bursary_params
      {
        applying_for_bursary: params[:custom_bursary_tier] != NONE_TYPE,
        applying_for_grant: params[:applying_for_grant] == "true",
        applying_for_scholarship: false,
        bursary_tier: params[:custom_bursary_tier] == NONE_TYPE ? nil : params[:custom_bursary_tier],
      }
    end

    def fields_to_ignore_before_save
      NON_TRAINEE_FIELDS
    end
  end
end
