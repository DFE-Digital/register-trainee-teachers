# frozen_string_literal: true

module Withdrawal
  class DateForm < MultiDateForm
    FIELDS = [:withdraw_date].freeze

    attr_accessor(*FIELDS)

    validate :date_valid, unless: :uses_deferral_date?

    def withdraw_date
      date
    end

    def fields
      super.merge(
        date_field => date,
      )
    end

    def save!
      trainee.current_withdrawal.update!(date: withdraw_date)
      clear_stash
    end

    def uses_deferral_date?
      trainee.deferred? && trainee.defer_date.present?
    end

    def date
      return trainee.defer_date if uses_deferral_date?

      super
    end

  private

    def form_store_key
      :withdrawal_date
    end

    def date_field
      @date_field ||= :withdraw_date
    end
  end
end
