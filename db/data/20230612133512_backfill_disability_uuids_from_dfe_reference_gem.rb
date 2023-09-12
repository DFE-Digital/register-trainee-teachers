# frozen_string_literal: true

class BackfillDisabilityUuidsFromDfEReferenceGem < ActiveRecord::Migration[7.0]
  def up
    DfEReference::DisabilitiesQuery.all.find_each do |reference_data|
      name = Hesa::CodeSets::Disabilities::MAPPING[reference_data.hesa_code]
      disability = Disability.find_by(name:)
      disability&.update(uuid: reference_data.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
