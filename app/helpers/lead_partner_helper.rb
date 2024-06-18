# frozen_string_literal: true

module LeadPartnerHelper
  def lead_partner_urn_and_location(lead_partner)
    [
      "URN #{lead_partner.urn}",
      [lead_partner.school&.town, lead_partner.school&.postcode].select(&:present?).join(", "),
    ]
  end
end
