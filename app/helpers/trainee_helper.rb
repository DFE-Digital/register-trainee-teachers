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
    total_trainees_count_text = "#{total_trainees_count} #{'record'.pluralize(total_trainees_count)}"

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
    FeatureService.enabled?(:publish_course_details) && trainee.available_courses.present?
  end

  def trainee_draft_title(trainee)
    draft_or_apply_draft_caption = t("views.trainees.show.#{trainee.apply_application? ? 'apply_draft' : 'draft'}")

    tag.span(draft_or_apply_draft_caption, class: "govuk-caption-l") + tag.h1(trainee_name(trainee).presence || t("components.page_titles.trainees.show.#{trainee.apply_application? ? 'apply_draft' : 'draft'}"), class: "govuk-heading-l")
  end

  def checked?(filters, filter, value)
    filters && filters[filter]&.include?(value)
  end

  def label_for(attribute, value)
    I18n.t("activerecord.attributes.trainee.#{attribute.pluralize}.#{value}")
  end

  def invalid_data_message(form_section, degree)
    data = degree&.trainee&.apply_application&.invalid_data

    return if data&.dig("degrees", degree.slug, form_section).blank?

    t("components.invalid_data_text.static_text", query: data["degrees"][degree.slug][form_section])
  end
end
