# frozen_string_literal: true

module PageObjects
  module Trainees
    class Withdrawal < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/withdraw"

      element :withdraw_date_day, "#withdrawal_form_date_3i"
      element :withdraw_date_month, "#withdrawal_form_date_2i"
      element :withdraw_date_year, "#withdrawal_form_date_1i"

      element :additional_withdraw_reason, "#withdrawal-form-additional-withdraw-reason-field"

      element :continue, "input[name='commit']"

      section :deferral_notice, PageObjects::Sections::DeferralNotice, ".deferral-notice"
    end
  end
end
