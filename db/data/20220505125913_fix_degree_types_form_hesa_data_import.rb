# frozen_string_literal: true

class FixDegreeTypesFormHesaDataImport < ActiveRecord::Migration[6.1]
  def up
    Hesa::CodeSets::DegreeTypes::MAPPING.each do |hesa_code, hesa_degree_type|
      register_degree_type = Dttp::CodeSets::DegreeTypes::MAPPING.find { |_, v| v[:hesa_code].to_i == hesa_code.to_i }&.first
      if register_degree_type
        Degree.where(uk_degree: hesa_degree_type).update_all(uk_degree: register_degree_type)
        Degree.where(non_uk_degree: hesa_degree_type).update_all(non_uk_degree: register_degree_type)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
