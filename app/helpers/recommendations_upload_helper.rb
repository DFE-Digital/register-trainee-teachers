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

  def from_to(from, to)
    from == to ? from : "#{from} to #{to}"
  end

  # We can't use url_for(:back) because if the user proceeds to 'Change' and
  # presses back, they would get stuck in a loop between 'Change' and 'Check'.
  def back_url_for_check_page(recommendations_upload)
    if recommendations_upload.error_rows.any?
      # This means the user skipped fixing errors, so 'Back' goes to errors page.
      bulk_update_recommendations_upload_recommendations_errors_url(recommendations_upload)
    else
      bulk_update_recommendations_upload_summary_path(recommendations_upload)
    end
  end
end
