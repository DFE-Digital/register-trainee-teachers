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

  def trainees_page_title(trainees, total_trainees_count)
    total_pages = trainees.total_pages
    total_trainees_count_text = total_trainees_count.to_s + " record".pluralize(@filtered_trainees.count)

    if total_pages <= 1
      return I18n.t("components.page_titles.trainees.index",
                    total_trainees_count_text: total_trainees_count_text)
    end

    I18n.t(
      "components.page_titles.trainees.paginated_index",
      current_page: trainees.current_page,
      total_pages: total_pages,
      total_trainees_count_text: total_trainees_count_text,
    )
  end
end
