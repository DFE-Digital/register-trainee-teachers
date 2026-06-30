# frozen_string_literal: true

class RestoreProvidersAccreditation < ActiveRecord::Migration[8.1]
  PROVIDERS = [
    { code: "B60", name: "Bradford College", accreditation_id: "5564" },
    { code: "B84", name: "Brunel University London", accreditation_id: "1504" },
    { code: "T11", name: "Teach East SCITT", accreditation_id: "5631" },
    { code: "F82", name: "Forest Independent Primary Collegiate SCITT", accreditation_id: "5517" },
    { code: "L06", name: "North East SCITT", accreditation_id: "5609" },
    { code: "2B2", name: "Yorkshire and Humber Teacher Training", accreditation_id: "5700" },
    { code: "C99", name: "University of Cumbria", accreditation_id: "1529" },
    { code: "E14", name: "University of East Anglia", accreditation_id: "1544" },
    { code: "G70", name: "University of Greenwich", accreditation_id: "1548" },
    { code: "S90", name: "University of Sussex", accreditation_id: "1564" },
    { code: "B80", name: "University of the West of England", accreditation_id: "1565" },
    { code: "2ET", name: "Prince Henry's High School and South Worcestershire SCITT", accreditation_id: "5711" },
  ].freeze

  def up
    PROVIDERS.each do |attrs|
      provider = Provider.find_by!(code: attrs[:code])

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
