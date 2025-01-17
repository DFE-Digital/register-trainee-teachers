# frozen_string_literal: true

class SetUrnForLeedsScitt < ActiveRecord::Migration[7.2]
  def up
    # NOTE: Leeds Trinity University 133838 for Leeds Scitt instead of 70165
    # As it is available from https://get-information-schools.service.gov.uk/Establishments/Establishment/Details/133838
    # We have no idea where 70165 comes from other then from https://assets.publishing.service.gov.uk/media/673618bc37aabe56c41611aa/Initial_teacher_education_inspection_data_as_at_31_August_2024.csv/preview
    lead_partner = LeadPartner.scitt.find_by(ukprn: "00005568")
    lead_partner.update(urn: 133838)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
