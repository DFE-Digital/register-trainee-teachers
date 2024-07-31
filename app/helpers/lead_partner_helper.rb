# frozen_string_literal: true

module LeadPartnerHelper
  def lead_partner_urn_and_location(lead_partner)
    [
      "URN #{lead_partner.urn}",
      [lead_partner.school&.town, lead_partner.school&.postcode].select(&:present?),
    ].flatten.join(", ")
  end

  def lead_partner_row(not_applicable: false)
    mappable_field(
      not_applicable ? t(:not_applicable) : lead_partner_detail(lead_partner),
      t("components.lead_partner_and_employing_school_details.lead_partner_key"),
      change_paths(:lead),
    )
  end

  def lead_partner_detail(lead_partner)
    return tag.p(t("components.confirmation.not_provided_from_hesa_update"), class: "govuk-body") if lead_partner.blank? && trainee.hesa_record?
    return unless lead_partner

    tag.p(lead_partner.name, class: "govuk-body") + tag.span(lead_partner_urn_and_location(lead_partner), class: "govuk-hint")
  end
end
