# frozen_string_literal: true
module Withdrawal
  class ReasonForm < TraineeForm
    validates_presence_of :reason_ids
    validate :unknown_exclusively

    FIELDS = %i[reason_ids].freeze

    attr_accessor(*FIELDS)

    def reasons
      WithdrawalReason.where(id: reason_ids)
    end
  
  private

    def unknown_exclusively
      if false # TODO
        errors.add(:reason_ids, :unknown_exclusively)
      end
    end

    def form_store_key
      :withdrawal_reasons
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      fields_from_store.merge(params).symbolize_keys.slice(*FIELDS).tap do |f|
        f[:reason_ids] = f[:reason_ids].map(&:to_i).reject(&:zero?) if f[:reason_ids]
      end
    end
  end
end
