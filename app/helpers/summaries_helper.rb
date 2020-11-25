# frozen_string_literal: true

module SummariesHelper
  def date_for_summary_view(date)
    date.strftime("%-d %B %Y")
  end
end
