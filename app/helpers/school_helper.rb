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
    return employing_setting_row if trainee.requires_employing_setting?

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

  # Early years teacher degree apprenticeship: the apprentice employing setting,
  # with its address and URN, or "No URN" for a setting typed in.
  def employing_setting_row
    mappable_field(
      employing_setting_detail,
      t("components.training_partner_and_employing_school_details.employing_setting_key"),
      edit_trainee_employing_settings_urn_path(trainee),
    )
  end

  def employing_setting_detail
    # A setting chosen in the search before its details were asked for has only the GIAS record.
    school = School.find_by(id: employing_setting_value(:employing_school_id))
    name = employing_setting_value(:employing_school_name) || school&.name
    return school_detail(nil) if name.blank?

    address = [
      employing_setting_value(:employing_school_address_line_one),
      employing_setting_value(:employing_school_address_line_two),
      employing_setting_value(:employing_school_town) || school&.town,
      employing_setting_value(:employing_school_postcode) || school&.postcode,
    ].compact_blank.join(", ")
    urn = employing_setting_value(:employing_school_urn) || school&.urn
    urn_text = urn.present? ? "URN #{urn}" : t("components.training_partner_and_employing_school_details.no_urn")

    tag.p(name, class: "govuk-body") + tag.span(safe_join([address.presence, urn_text].compact, tag.br), class: "govuk-hint")
  end

  # From the form being confirmed, when there is one, otherwise the trainee.
  def employing_setting_value(field)
    source = respond_to?(:employing_setting_source, true) ? employing_setting_source : trainee
    source = trainee unless source.respond_to?(field)
    source.public_send(field).presence
  end

  def mappable_field(field_value, field_label, action_url)
    { field_value:, field_label:, action_url: }
  end
end
