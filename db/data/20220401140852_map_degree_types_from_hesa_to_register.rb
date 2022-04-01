# frozen_string_literal: true

class MapDegreeTypesFromHesaToRegister < ActiveRecord::Migration[6.1]
  def up
    {
      "BA (Hons) /Education" => "BA/Education",
      "BEd (Hons)" => "BEd",
      "BSc (Hons) /Education" => "BSc/Education",
      "BTech (Hons) /Education" => "BTech/Education",
      "BA (Hons) with intercalated PGCE" => "BA with intercalated PGCE",
      "BSc (Hons) with intercalated PGCE" => "Bachelor of Science",
      "BA (Hons) Combined Studies/Education of the Deaf" => "BA Combined Studies/Education of the Deaf",
    }.each do |hesa_degree_type, register_degree_type|
      Degree.where(uk_degree: hesa_degree_type).update_all(uk_degree: register_degree_type)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
