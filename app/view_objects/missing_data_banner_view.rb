# frozen_string_literal: true

class MissingDataBannerView
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Context

  include CourseDetailsHelper
  include DegreesHelper

  def initialize(missing_fields, trainee)
    @missing_fields = missing_fields
    @trainee = trainee
  end

  def header
    I18n.t("views.missing_data_banner_view.header")
  end

  def content
    return unless missing_fields.any?

    tag.ul(class: "govuk-list app-notice-banner__list") do
      render_links
    end
  end

private

  attr_reader :trainee, :missing_fields

  def render_links
    safe_join(
      missing_fields.map do |field|
        tag.li(
          link_to(
            link_text(field).html_safe,
            link_path(field),
            class: "govuk-notification-banner__link",
          ),
        )
      end,
    )
  end

  def link_path(field)
    path_helper = I18n.t("views.missing_data_banner_view.missing_field_link.#{field}")

    case path_helper
    when "course_path"
      path_for_course_details(trainee)
    when "degree_path"
      path_for_degrees(trainee)
    else
      public_send(path_helper, trainee)
    end
  end

  def link_text(field)
    I18n.t("views.missing_data_banner_view.missing_field_text", missing_field: display_name(field))
  end

  def display_name(field)
    I18n.t("views.missing_data_view.missing_fields_mapping.#{field}")
  end
end
