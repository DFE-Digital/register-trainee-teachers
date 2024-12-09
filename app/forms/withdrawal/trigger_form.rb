# frozen_string_literal: true

module Withdrawal
  class TriggerForm < TraineeForm
    FIELDS = %i[
      trigger
    ].freeze

    attr_accessor(*FIELDS)

    validates :trigger, presence: true, inclusion: { in: %w[provider trainee] }

    def save!
      assign_attributes_to_trainee
      trainee.save
      clear_stash
    end

    private

    def form_store_key
      :withdrawal_trigger
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      fields_from_store.merge(params).symbolize_keys.slice(*FIELDS)
    end
  end
end
