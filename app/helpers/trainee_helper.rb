# frozen_string_literal: true

module TraineeHelper
  def trainee_name(trainee)
    [trainee.first_names, trainee.middle_names, trainee.last_name]
      .compact
      .reject(&:empty?)
      .join(" ")
  end

  def view_trainee(trainee)
    if trainee.draft?
      review_draft_trainee_path(trainee)
    else
      trainee_path(trainee)
    end
  end

  def trainees_page_title(trainees)
    total_pages = trainees.total_pages
    return "trainees.index" if total_pages <= 1

    I18n.t(
      "components.page_titles.trainees.paginated_index",
      current_page: trainees.current_page,
      total_pages: total_pages,
    )
  end
end
