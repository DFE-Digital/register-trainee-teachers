# frozen_string_literal: true

module SchoolHelper
  DisplaySchool = Struct.new(:name, :urn, :town, :postcode, keyword_init: true)

  def school_urn_and_location(school)
    urn = "URN #{school.urn}" if school.urn.present?
    [urn, school.town, school.postcode].compact_blank.join(", ")
  end

  def school_detail(school)
    return tag.p(t("components.confirmation.not_provided_from_hesa_update"), class: "govuk-body") if school.blank? && trainee.hesa_record?
    return unless school

    tag.p(school.name, class: "govuk-body") + tag.span(school_urn_and_location(school), class: "govuk-hint")
  end

  def employing_school_row(not_applicable: false)
    return unless trainee.requires_employing_school? || trainee.requires_assessment_only_employing_school?

    mappable_field(
      not_applicable ? t(:not_applicable) : school_detail(employing_school_for_display),
      t("components.training_partner_and_employing_school_details.employing_school_key"),
      change_paths(:employing),
    )
  end

  def employing_school_for_display
    school = employing_school if respond_to?(:employing_school)
    school ||= trainee.employing_school
    return school if school.present?
    return if trainee.employing_school_name.blank?

    DisplaySchool.new(
      name: trainee.employing_school_name,
      urn: trainee.employing_school_urn,
      town: nil,
      postcode: trainee.employing_school_postcode,
    )
  end

  def mappable_field(field_value, field_label, action_url)
    { field_value:, field_label:, action_url: }
  end
end
