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
      trainee_review_drafts_path(trainee)
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
    draft_caption = t("views.trainees.show.draft")

    tag.span(draft_caption, class: "govuk-caption-l") + tag.h1(trainee_name(trainee).presence || t("components.page_titles.trainees.show.#{trainee.apply_application? ? 'apply_draft' : 'draft'}"), class: "govuk-heading-l govuk-!-margin-bottom-8")
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

  def invalid_data_class(form:, field:)
    return form_error_class(form, field) if form.errors.any?

    if invalid_data_message(field, form.degree)
      "govuk-form-group govuk-inset-text app-inset-text--narrow-border app-inset-text--important app-inset-text--no_padding"
    else
      "govuk-form-group"
    end
  end

  def form_error_class(form, field)
    form.errors.messages.keys.include?(field.to_sym) ? "govuk-form-group govuk-form-group--error" : "govuk-form-group"
  end

  # Use this method if you're preloading courses in bulk as it won't make further database calls
  def course_name_for(trainee)
    trainee.provider&.courses&.find { |course| course.uuid == trainee.course_uuid }&.name
  end
end
