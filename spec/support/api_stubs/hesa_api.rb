# frozen_string_literal: true

module ApiStubs
  class HesaApi
    attr_reader :raw_xml, :attributes, :student_node, :student_attributes

    def initialize(attributes = {})
      @attributes = attributes
      @raw_xml = read_fixture_file("hesa/itt_record.xml")
      xml_doc = Nokogiri::XML(raw_xml)
      @student_node = override_node_tags(xml_doc.xpath("//ITTRecord/Student").first)
      @student_attributes = Hesa::Parsers::IttRecord.to_attributes(student_node:)
    end

  private

    def override_node_tags(student_node)
      attributes.each do |key, value|
        value = "NULL" if value.nil?
        student_node.xpath("//#{Hesa::Parsers::IttRecord::TAG_MAP[key]}").first.content = value
      end
      student_node
    end

    def read_fixture_file(filename)
      File.read(fixture_file_path(filename))
    end

    def fixture_file_path(filename)
      Rails.root.join("spec/support/fixtures/#{filename}").to_s
    end
  end
end
