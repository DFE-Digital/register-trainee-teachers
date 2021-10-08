# frozen_string_literal: true

module Funding
  class BursaryForm < TraineeForm
    FIELDS = %i[
      funding_type
      applying_for_bursary
      bursary_tier
      applying_for_scholarship
      applying_for_grant
    ].freeze

    NON_TRAINEE_FIELDS = %i[
      funding_type
    ].freeze

    NONE_TYPE = "none"
    FUNDING_TYPES = (Trainee.bursary_tiers.keys + FUNDING_TYPE_ENUMS.values + [NONE_TYPE]).freeze

    attr_accessor(*FIELDS)

    validates :funding_type, inclusion: { in: FUNDING_TYPES }

    delegate :can_apply_for_scholarship?, :can_apply_for_tiered_bursary?,
             :can_apply_for_grant?, :grant_amount,
             :scholarship_amount, to: :funding_manager

    def initialize(trainee, params: {}, user: nil, store: FormStore)
      params = add_fields_from_params(params)
      super(trainee, params: params, user: user, store: store)
    end

    def view_partial
      if can_apply_for_grant?
        "grant_form"
      elsif can_apply_for_tiered_bursary?
        "tiered_bursary_form"
      else
        "non_tiered_bursary_form"
      end
    end

  private

    def compute_fields
      opts = trainee.attributes.symbolize_keys.slice(*FIELDS)
      opts = add_funding_type_from_db(opts)
      opts.merge!(new_attributes)
      opts
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end

    def add_funding_type_from_db(opts)
      opts[:funding_type] =
        if trainee.bursary_tier.present?
          trainee.bursary_tier
        elsif trainee.applying_for_bursary?
          FUNDING_TYPE_ENUMS[:bursary]
        elsif trainee.applying_for_scholarship?
          FUNDING_TYPE_ENUMS[:scholarship]
        elsif trainee.applying_for_grant?
          FUNDING_TYPE_ENUMS[:grant]
        elsif (trainee.applying_for_bursary == false) ||
          (trainee.applying_for_scholarship == false) ||
          (trainee.applying_for_grant == false)
          NONE_TYPE
        end
      opts
    end

    def add_fields_from_params(opts)
      case opts[:funding_type]
      when *Trainee.bursary_tiers.keys
        opts[:bursary_tier] = opts[:funding_type]
        opts[:applying_for_bursary] = true
        opts[:applying_for_scholarship] = false
        opts[:applying_for_grant] = false
      when FUNDING_TYPE_ENUMS[:bursary]
        opts[:bursary_tier] = nil
        opts[:applying_for_bursary] = true
        opts[:applying_for_scholarship] = false
        opts[:applying_for_grant] = false
      when FUNDING_TYPE_ENUMS[:scholarship]
        opts[:bursary_tier] = nil
        opts[:applying_for_bursary] = false
        opts[:applying_for_scholarship] = true
        opts[:applying_for_grant] = false
      when FUNDING_TYPE_ENUMS[:grant]
        opts[:bursary_tier] = nil
        opts[:applying_for_bursary] = false
        opts[:applying_for_scholarship] = false
        opts[:applying_for_grant] = true
      when NONE_TYPE
        opts[:bursary_tier] = nil
        opts[:applying_for_bursary] = false
        opts[:applying_for_scholarship] = false
        opts[:applying_for_grant] = false
      end
      opts
    end

    def form_store_key
      :bursary
    end

    def fields_to_ignore_before_save
      NON_TRAINEE_FIELDS
    end
  end
end
