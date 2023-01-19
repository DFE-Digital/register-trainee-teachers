# frozen_string_literal: true

module Hesa
  class SyncStudents
    include ServicePattern

    attr_reader :collection_xml, :collection_reference

    def initialize
      from_date = Settings.hesa.current_collection_start_date
      @collection_reference = Settings.hesa.current_collection_reference
      @collection_xml = Client.get(url: "#{Settings.hesa.collection_base_url}/#{collection_reference}/#{from_date}")
    end

    def call
      return if collection_xml.empty?

      Nokogiri::XML::Reader(collection_xml).each do |node|
        next unless node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

        student_node = Nokogiri::XML(node.outer_xml).at("./Student")
        hesa_trainee = Hesa::Parsers::IttRecord.to_attributes(student_node:)
        hesa_student = Hesa::Student.find_or_initialize_by(hesa_id: hesa_trainee[:hesa_id])
        hesa_student.assign_attributes(hesa_trainee)
        hesa_student.collection_reference = collection_reference
        hesa_student.save
      end
    end
  end
end
