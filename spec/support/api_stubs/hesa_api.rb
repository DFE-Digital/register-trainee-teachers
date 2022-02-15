# frozen_string_literal: true

module ApiStubs
  class HesaApi
    TAG_MAP = {
      first_names: "F_FNAMES",
      last_name: "F_PSURNAME",
      email: "F_NQTEMAIL",
      date_of_birth: "F_BIRTHDTE",
      ethnic_background: "F_ETHNIC",
      gender: "F_SEXID",
      ukprn: "F_UKPRN",
      trainee_id: "F_OWNSTU",
      course_subject_one: "F_SBJCA1",
      course_subject_two: "F_SBJCA2",
      course_subject_three: "F_SBJCA3",
      itt_start_date: "F_PGAPPSTDT",
      employing_school_id: "F_SDEMPLOY",
      lead_school_id: "F_SDLEAD",
      reason_for_leaving: "F_RSNEND",
      study_mode: "F_MODE",
      course_min_age: "F_ITTPHSC",
      commencement_date: "F_ITTCOMDATE",
      training_initiative: "F_INITIATIVES1",
      hesa_id: "F_HUSID",
      applying_for_bursary: "F_FUNDCODE",
      international_address: "F_DOMICILE",
      end_date: "F_ENDDATE",
      disability: "F_DISABLE",
      bursary_tier: "F_BURSLEV",
      trn: "F_TREFNO",
      training_route: "F_ENTRYRTE",
      nationality: "F_NATION",
    }.freeze

    attr_reader :attributes, :student_node, :student_attributes

    def initialize(attributes = {})
      @attributes = attributes
      xml_doc = Nokogiri::XML(read_fixture_file("hesa/itt_record.xml"))
      @student_node = override_node_tags(xml_doc.xpath("//ITTRecord/Student").first)
      @student_attributes = Hesa::Parsers::IttRecord.to_attributes(student_node: student_node)
    end

  private

    def override_node_tags(student_node)
      attributes.each do |key, value|
        value = "NULL" if value.nil?
        student_node.xpath("//#{TAG_MAP[key]}").first.content = value
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
