# frozen_string_literal: true

class BackfillUnmappedHesaDegreeGrades < ActiveRecord::Migration[6.1]
  def up
    from_date = Settings.hesa.current_collection_start_date
    collection_reference = Settings.hesa.current_collection_reference
    url = "#{Settings.hesa.collection_base_url}/#{collection_reference}/#{from_date}"
    xml_response = Hesa::Client.get(url:)

    return unless xml_response.include?("ITTRecord")

    Nokogiri::XML::Reader(xml_response).each do |node|
      next unless node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

      student_node = Nokogiri::XML(node.outer_xml).at("./Student")
      hesa_trainee = Hesa::Parsers::IttRecord.to_attributes(student_node:)

      Degree.without_auditing do
        trainee = Trainee.find_by(hesa_id: hesa_trainee[:hesa_id])
        if trainee
          trainee.degrees.delete_all
          Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_trainee[:degrees])
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
