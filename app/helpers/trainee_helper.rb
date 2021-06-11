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
    total_trainees_count_text = pluralize(total_trainees_count, "record")

    if total_pages <= 1
      return I18n.t(
        "components.page_titles.trainees.index",
        total_trainees_count_text: total_trainees_count_text,
      )
    end

    I18n.t(
      "components.page_titles.trainees.paginated_index",
      current_page: trainees.current_page,
      total_pages: total_pages,
      total_trainees_count_text: total_trainees_count_text,
    )
  end

  def show_publish_courses?(trainee)
    courses_available = trainee.available_courses.present?

    FeatureService.enabled?(:publish_course_details) && courses_available
  end

  def last_updated_event_for(trainee)
    Trainees::CreateTimeline.call(trainee: trainee).first
  end

  def trainee_draft_title(trainee)
    name = trainee_name(trainee)
    title_suffix = "#{name.present? ? " for #{name}" : ''} "
    translation_prefix = t("views.trainees.show.#{trainee.apply_application? ? 'apply_draft' : 'draft'}")

    "#{translation_prefix}#{title_suffix}"
  end
end
