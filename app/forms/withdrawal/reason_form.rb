# frozen_string_literal: true

module Withdrawal
  class ReasonForm < TraineeForm
    validates_presence_of :reason_ids

    FIELDS = %i[reason_ids another_reason].freeze

    attr_accessor(*FIELDS)

    def reasons
      if provider_triggered?
        WithdrawalReason.where(name: WithdrawalReasons::PROVIDER_REASONS)
      else
        WithdrawalReason.where(name: WithdrawalReasons::TRAINEE_REASONS)
      end
    end

  private

    def provider_triggered?
      trigger_form.trigger == "provider"
    end

    def trigger_form
      @trigger_form ||= TriggerForm.new(trainee)
    end

    def compute_fields
      {
        reason_ids: [],
        another_reason: nil,
      }.merge(new_attributes)
    end

    def new_attributes
      fields_from_store.merge(params).symbolize_keys.tap do |f|
        f[:reason_ids] = f[:reason_ids].compact_blank.map(&:to_i) if f[:reason_ids]
      end
    end

    def form_store_key
      :withdrawal_reasons
    end
  end
end
