# frozen_string_literal: true

module TrainingPartnerHelper
  def training_partner_urn_and_location(training_partner)
    [
      "URN #{training_partner.urn}",
      [training_partner.school&.town, training_partner.school&.postcode].compact_blank,
    ].flatten.join(", ")
  end

  def training_partner_row(not_applicable: false)
    mappable_field(
      not_applicable ? t(:not_applicable) : training_partner_detail(training_partner),
      t("components.training_partner_and_employing_school_details.training_partner_key"),
      change_paths(:training_partner),
    )
  end

  def training_partner_detail(training_partner)
    return tag.p(t("components.confirmation.not_provided_from_hesa_update"), class: "govuk-body") if training_partner.blank? && trainee.hesa_record?
    return unless training_partner

    tag.p(training_partner.name, class: "govuk-body") + tag.span(training_partner_urn_and_location(training_partner), class: "govuk-hint")
  end
end
