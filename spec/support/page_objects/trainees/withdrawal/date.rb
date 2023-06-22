# frozen_string_literal: true

module PageObjects
  module Trainees
    module Withdrawal
      class Date < PageObjects::Base
        include PageObjects::Helpers

        set_url "/trainees/{id}/withdrawal/date/edit"

        element :withdraw_date_day, "#withdrawal_date_form_date_3i"
        element :withdraw_date_month, "#withdrawal_date_form_date_2i"
        element :withdraw_date_year, "#withdrawal_date_form_date_1i"

        element :continue, "button[type='submit']"

        section :duplicate_notice, PageObjects::Sections::DuplicateNotice, ".duplicate-notice"
        section :deferral_notice, PageObjects::Sections::DeferralNotice, ".deferral-notice"
      end
    end
  end
end
