# frozen_string_literal: true

module ComponentHelper
  def summary_card_row_for(selector)
    ".govuk-summary-list__row.#{selector} .govuk-summary-list__value"
  end
end
