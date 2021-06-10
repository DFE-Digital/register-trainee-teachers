# frozen_string_literal: true

module SchoolHelper
  def school_urn_and_location(school)
    ["URN #{school.urn}", school.town, school.postcode].select(&:present?).join(", ")
  end

  def school_detail(school)
    return t(:answer_missing) unless school

    tag.p(school.name, class: "govuk-body") + tag.span(school_urn_and_location(school), class: "govuk-hint")
  end

  def school_rows
    [lead_school_row, employing_school_row].compact
  end

  def lead_school_row
    {
      key: t("components.school_details.lead_school_key"),
      value: school_detail(lead_school),
      action: change_link(:lead),
    }
  end

  def employing_school_row
    return unless trainee.requires_employing_school?

    {
      key: t("components.school_details.employing_school_key"),
      value: school_detail(employing_school),
      action: change_link(:employing),
    }
  end

  def change_link(school_type)
    govuk_link_to("Change<span class='govuk-visually-hidden'> #{school_type} school</span>".html_safe, change_paths(school_type))
  end
end
