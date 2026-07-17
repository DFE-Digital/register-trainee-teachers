# frozen_string_literal: true

module Withdrawal
  class ReasonForm < TraineeForm
    validate :reasons_present?
    validate :reasons_valid_for_trigger?
    validates :another_reason, presence: true, if: :another_reason_id_provided?
    validates :safeguarding_concern_reasons, presence: true, if: :safeguarding_concern?

    delegate :trigger, to: :trigger_form

    FIELDS = %i[reason_ids another_reason safeguarding_concern_reasons].freeze

    attr_accessor(*FIELDS)

    def withdrawal_reasons
      WithdrawalReason.where(id: reason_ids)
    end

    def reasons
      names = WithdrawalReasons.for_trigger(trigger)
      WithdrawalReason.where(name: names).sort_by { |reason| names.index(reason.name) }
    end

    def save!
      withdrawal = trainee.current_withdrawal
      attrs = {}.tap do |h|
        h[:another_reason] = another_reason if another_reason.present?
        h[:safeguarding_concern_reasons] = safeguarding_concern_reasons if safeguarding_concern_reasons.present?
      end
      withdrawal.update!(attrs)

      reason_ids.each do |reason_id|
        withdrawal.trainee_withdrawal_reasons.create!(
          withdrawal_reason_id: reason_id,
        )
      end

      clear_stash
    end

  private

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

    def reasons_present?
      return true unless reason_ids.empty?

      error = I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.reason_ids.#{trigger_form.trigger}.blank").html_safe

      errors.add(:reason_ids, error)
    end

    def reasons_valid_for_trigger?
      return true if reason_ids.empty? || (reason_ids - reasons.map(&:id)).empty?

      errors.add(:reason_ids, :invalid)
    end

    def another_reason_id_provided?
      WithdrawalReason.where("name like ?", "%another_reason").exists?(id: reason_ids)
    end

    def safeguarding_concern?
      WithdrawalReason.where(name: WithdrawalReasons::SAFEGUARDING_CONCERNS).exists?(id: reason_ids)
    end
  end
end
