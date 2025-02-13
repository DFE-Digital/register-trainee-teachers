# frozen_string_literal: true

module Withdrawal
  class FutureInterestForm < TraineeForm
    FIELDS = %i[future_interest].freeze

    attr_accessor(*FIELDS)

    validates :future_interest, presence: true, inclusion: { in: %w[yes no unknown] }

    def save!
      withdrawal = trainee.current_withdrawal
      withdrawal.update!(future_interest:)

      clear_stash
    end

  private

    def form_store_key
      :future_interest
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      fields_from_store.merge(params).symbolize_keys.slice(*FIELDS)
    end
  end
end
