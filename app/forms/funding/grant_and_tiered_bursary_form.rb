# frozen_string_literal: true

module Funding
  class GrantAndTieredBursaryForm < TraineeForm
    FIELDS = %i[
      applying_for_bursary
      bursary_tier
      custom_bursary_tier
      custom_applying_for_grant
      applying_for_scholarship
      applying_for_grant
    ].freeze

    NON_TRAINEE_FIELDS = %i[
      custom_bursary_tier
      custom_applying_for_grant
    ].freeze

    FUNDING_TYPES = (Trainee.bursary_tiers.keys + FUNDING_TYPE_ENUMS.values).freeze

    NONE_TYPE = "none"

    attr_accessor(*FIELDS)

    validates :custom_applying_for_grant, inclusion: { in: %w[yes no] }, if: :can_apply_for_grant?

    validates :custom_bursary_tier, inclusion: { in: Trainee.bursary_tiers.keys + [NONE_TYPE] }

    delegate :applicable_available_funding, :can_apply_for_tiered_bursary?,
             :can_apply_for_grant?,
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

      if params[:custom_applying_for_grant].present?
        fields[:custom_applying_for_grant] = params[:custom_applying_for_grant]
      elsif trainee.applying_for_grant.nil?
        fields[:custom_applying_for_grant] = nil
      else
        fields[:custom_applying_for_grant] = trainee.applying_for_grant ? "yes" : "no"
      end

      fields.merge!(new_attributes)
      fields
    end

    def new_attributes
      if params.present?
        fields_from_store.merge(grant_and_tiered_bursary_params).symbolize_keys
      else
        fields_from_store.symbolize_keys
      end
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end

    def grant_and_tiered_bursary_params
      {
        applying_for_bursary: params[:custom_bursary_tier] != NONE_TYPE,
        applying_for_grant: calculate_applying_for_grant,
        applying_for_scholarship: false,
        bursary_tier: params[:custom_bursary_tier] == NONE_TYPE ? nil : params[:custom_bursary_tier],
      }
    end

    def calculate_applying_for_grant
      return false unless can_apply_for_grant?

      params[:custom_applying_for_grant].nil? ? nil : params[:custom_applying_for_grant] == "yes"
    end

    def fields_to_ignore_before_save
      NON_TRAINEE_FIELDS
    end
  end
end
