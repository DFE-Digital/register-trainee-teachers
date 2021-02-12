# frozen_string_literal: true

module SummaryHelper
  def date_for_summary_view(date)
    date&.strftime("%-d %B %Y")
  end
end
