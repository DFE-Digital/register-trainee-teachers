# frozen_string_literal: true
module Withdrawal
  class DateForm < MultiDateForm
    validate :date_valid

    def withdraw_date
      date
    end

  private

    def date_field
      @date_field ||= :withdraw_date
    end

    def form_store_key
      :withdrawal_date
    end
  end
end
