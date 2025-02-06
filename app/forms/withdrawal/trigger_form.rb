# frozen_string_literal: true

module Withdrawal
  class TriggerForm < TraineeForm
    FIELDS = %i[trigger withdrawal_reasons].freeze

    attr_accessor(*FIELDS)

    validates :trigger, presence: true, inclusion: { in: %w[provider trainee] }

    def stash
      clear_withdrawal_reasons if trigger_changed?
      super
    end

    def save!
      withdrawal = trainee.current_withdrawal
      withdrawal.update!(trigger:) if trigger.present?
      clear_stash
    end

  private

    def form_store_key
      :trigger
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      fields_from_store.merge(params).symbolize_keys.slice(*FIELDS)
    end

    def clear_withdrawal_reasons
      store.set(trainee.id, :withdrawal_reasons, {})
    end

    def trigger_changed?
      return false if store.get(trainee.id, :trigger).nil?

      store.get(trainee.id, :trigger)["trigger"] != trigger
    end
  end
end
