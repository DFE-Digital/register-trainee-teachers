# frozen_string_literal: true

module SchoolHelper
  def school_urn_and_location(school)
    ["URN #{school.urn}", school.town, school.postcode].select(&:present?).join(", ")
  end

  def school_detail(school)
    return unless school

    tag.p(school.name, class: "govuk-body") + tag.span(school_urn_and_location(school), class: "govuk-hint")
  end

  def lead_school_row(not_applicable: false)
    mappable_field(
      not_applicable ? t(:not_applicable) : school_detail(lead_school),
      t("components.school_details.lead_school_key"),
      change_paths(:lead),
    )
  end

  def employing_school_row(not_applicable: false)
    return unless trainee.requires_employing_school?

    mappable_field(
      not_applicable ? t(:not_applicable) : school_detail(employing_school),
      t("components.school_details.employing_school_key"),
      change_paths(:employing),
    )
  end
end
