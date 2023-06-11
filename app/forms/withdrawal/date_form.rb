# frozen_string_literal: true
module Withdrawal
  class DateForm < MultiDateForm
    FIELDS = [:withdraw_date]

    attr_accessor(*FIELDS)

    validate :date_valid

    def withdraw_date
      date
    end

    def fields
      super.merge(
        date_field => date
      )
    end

    def save!
      assign_attributes_to_trainee
      trainee.save
      clear_stash
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
