# frozen_string_literal: true

class SetUrnsForHeiLeadPartners < ActiveRecord::Migration[7.2]
  def up
    # Update all HEI Lead Partners with their own URN so they can be assigned to trainees via the CSV bulk add trainees feature

    # Brunel University London
    LeadPartner.hei.find_by(ukprn: "10000961").update(urn: 133897)
    # The University Of Bolton
    LeadPartner.hei.find_by(ukprn: "10006841").update(urn: 133794)
    # The University Of East Anglia
    LeadPartner.hei.find_by(ukprn: "10007789").update(urn: 133853)
    # University of Cumbria
    LeadPartner.hei.find_by(ukprn: "10007842").update(urn: 135398)
    # University of Greenwich
    LeadPartner.hei.find_by(ukprn: "10007146").update(urn: 133876)
    # University of Sussex
    LeadPartner.hei.find_by(ukprn: "10007806").update(urn: 133795)
    # University of the West of England, Bristol
    LeadPartner.hei.find_by(ukprn: "10007164").update(urn: 133798)
    # University of Durham
    LeadPartner.hei.find_by(ukprn: "10007143").update(urn: 133812)
  end

  def down
    LeadPartner.hei.where(urn: [133897, 133794, 133853, 135398, 133876, 133795, 133798, 133812]).update_all(urn: nil)
  end
end
