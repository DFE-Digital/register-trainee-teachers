# frozen_string_literal: true

class RestoreProvidersAccreditation < ActiveRecord::Migration[8.1]
  PROVIDERS = [
    { name: "Bradford College", accreditation_id: "5564" },
    { name: "Brunel University London", accreditation_id: "1504" },
    { name: "Teach East SCITT", accreditation_id: "5631" },
    { name: "Forest Independent Primary Collegiate SCITT", accreditation_id: "5517" },
    { name: "North East SCITT", accreditation_id: "5609" },
    { name: "Yorkshire and Humber Teacher Training", accreditation_id: "5700" },
    { name: "University of Cumbria", accreditation_id: "1529" },
    { name: "University of East Anglia", accreditation_id: "1544" },
    { name: "University of Greenwich", accreditation_id: "1548" },
    { name: "University of Sussex", accreditation_id: "1564" },
    { name: "University of the West of England", accreditation_id: "1565" },
    { name: "Prince Henry's High School and South Worcestershire SCITT", accreditation_id: "5711" },
  ].freeze

  def up
    PROVIDERS.each do |attrs|
      provider = Provider.find_by!(accreditation_id: attrs[:accreditation_id])

      RestoreProvidersAccreditationService.call(
        provider: provider,
        name: attrs[:name],
        accreditation_id: attrs[:accreditation_id],
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
