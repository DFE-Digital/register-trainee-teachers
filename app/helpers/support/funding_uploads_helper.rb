# frozen_string_literal: true

module Support
  module FundingUploadsHelper
    def funding_upload_month_options(selected = nil)
      options_for_select([["Choose month", nil]] + Date::MONTHNAMES.compact.map.with_index(1) { |month, index| [month, index] }, selected:)
    end
  end
end
