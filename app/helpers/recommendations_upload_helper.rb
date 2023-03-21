# frozen_string_literal: true

module RecommendationsUploadHelper
  include ApplicationHelper

  def qts_or_eyts(rows)
    if rows.all?(&:qts?)
      "QTS"
    elsif rows.all?(&:eyts?)
      "EYTS"
    else
      "QTS or EYTS"
    end
  end
end
