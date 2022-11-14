# frozen_string_literal: true

namespace :hesa do
  desc "Update hesa_students table with the latest collection data from HESA"
  task update_students_table: :environment do
    from_date = Settings.hesa.current_collection_start_date
    collection_reference = Settings.hesa.current_collection_reference
    url = "#{Settings.hesa.collection_base_url}/#{collection_reference}/#{from_date}"
    xml_response = Hesa::Client.get(url: url)

    total_nodes = Nokogiri::XML(xml_response).root.children.size
    puts "Total student nodes: #{total_nodes}"
    bar = ProgressBar.create(total: total_nodes)

    Nokogiri::XML::Reader(xml_response).each do |node|
      next unless node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

      student_node = Nokogiri::XML(node.outer_xml).at("./Student")
      hesa_trainee = Hesa::Parsers::IttRecord.to_attributes(student_node: student_node)
      hesa_student = Hesa::Student.find_or_initialize_by(hesa_id: hesa_trainee[:hesa_id])
      hesa_student.assign_attributes(hesa_trainee)
      hesa_student.collection_reference = collection_reference
      hesa_student.save

      bar.increment
    end
  end
end
