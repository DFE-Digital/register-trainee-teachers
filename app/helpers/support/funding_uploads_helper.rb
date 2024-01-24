# frozen_string_literal: true

module Support
  module FundingUploadsHelper
    def funding_upload_month_options(selected = nil)
      options_for_select([["Choose month", nil]] + Date::MONTHNAMES.compact.map.with_index(1) { |month, index| [month, index] }, selected:)
    end

    def funding_upload_last_completed_for(funding_upload)
      return "Never completed" if funding_upload.blank?

      funding_upload.created_at.strftime("%d %B %Y")
    end

    def funding_upload_month_for(funding_upload)
      return if funding_upload.blank?

      Date::MONTHNAMES[funding_upload.month]
    end
  end
end
