# frozen_string_literal: true

module Withdrawal
  class ReasonForm < TraineeForm
    validates_presence_of :reason_ids

    FIELDS = %i[reason_ids another_reason].freeze

    attr_accessor(*FIELDS)

    def withdrawal_reasons
      WithdrawalReason.where(id: reason_ids)
    end

    def reasons
      if provider_triggered?
        WithdrawalReason.where(name: WithdrawalReasons::PROVIDER_REASONS).sort_by do |reason|
          WithdrawalReasons::PROVIDER_REASONS.index(reason.name)
        end
      else
        WithdrawalReason.where(name: WithdrawalReasons::TRAINEE_REASONS).sort_by do |reason|
          WithdrawalReasons::TRAINEE_REASONS.index(reason.name)
        end
      end
    end

    def save!
      withdrawal = trainee.trainee_withdrawals.last
      withdrawal.update!(another_reason:) if another_reason.present?

      reason_ids.each do |reason_id|
        withdrawal.trainee_withdrawal_reasons.create!(
          withdrawal_reason_id: reason_id,
        )
      end

      clear_stash
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
