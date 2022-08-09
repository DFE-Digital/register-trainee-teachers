# frozen_string_literal: true

module Hesa
  module Parsers
    class IttRecord
      TAG_MAP = {
        first_names: "F_FNAMES",
        last_name: "F_SURNAME",
        email: "F_NQTEMAIL",
        date_of_birth: "F_BIRTHDTE",
        ethnic_background: "F_ETHNIC",
        gender: "F_SEXID",
        ukprn: "F_UKPRN",
        trainee_id: "F_OWNSTU",
        course_subject_one: "F_SBJCA1",
        course_subject_two: "F_SBJCA2",
        course_subject_three: "F_SBJCA3",
        itt_start_date: "F_COMDATE",
        itt_end_date: "F_EXPECTEDENDDATE",
        employing_school_urn: "F_SDEMPLOY",
        lead_school_urn: "F_SDLEAD",
        mode: "F_MODE",
        course_age_range: "F_ITTPHSC",
        commencement_date: "F_ITTCOMDATE",
        training_initiative: "F_INITIATIVES1",
        hesa_id: "F_HUSID",
        disability: "F_DISABLE",
        end_date: "F_ENDDATE",
        reason_for_leaving: "F_RSNEND",
        bursary_level: "F_BURSLEV",
        trn: "F_TRN",
        training_route: "F_ENTRYRTE",
        nationality: "F_NATION",
        hesa_updated_at: "F_STATUS_TIMESTAMP",
        itt_aim: "F_ITTAIM",
        itt_qualification_aim: "F_QLAIM",
        fund_code: "F_FUNDCODE",
        study_length: "F_SPLENGTH",
        study_length_unit: "F_UNITLGTH",
        course_programme_title: "F_CTITLE",
        pg_apprenticeship_start_date: "F_PGAPPSTDT",
        year_of_course: "F_YEARPRG",
        degrees: "PREVIOUSQUALIFICATIONS",
        placements: "PLACEMENTS",
      }.freeze

      class << self
        def to_attributes(student_node:)
          student_attributes = Hash.from_xml(student_node.to_s)["Student"]
          student_attributes = convert_all_null_values_to_nil(student_attributes)
          TAG_MAP.inject({}) do |hash, (attribute_name, xml_tag_name)|
            tag_value = student_attributes[xml_tag_name]
            hash[attribute_name] = case attribute_name
                                   when :degrees then to_degrees_attributes(tag_value)
                                   when :placements then to_placement_attributes(tag_value)
                                   else tag_value
                                   end
            hash
          end
        end

        def to_degrees_attributes(qualifications)
          # If there's only one qualification, we get a hash. If there's more
          # than one, we get an array of hashes. Hence the need to wrap and
          # flatten to cover both cases.
          [qualifications&.values].flatten.compact.map do |qualification|
            {
              graduation_date: qualification["F_DEGENDDT"],
              degree_type: qualification["F_DEGTYPE"],
              subject: qualification["F_DEGSBJ1"],
              institution: qualification["F_DEGEST"],
              grade: qualification["F_DEGCLSS"],
              country: qualification["F_DEGCTRY"],
            }
          end
        end

        def to_placement_attributes(placements)
          [placements&.values].flatten.compact.map do |placement|
            {
              school_urn: placement["F_PLMNTSCH"],
            }
          end
        end

        def convert_all_null_values_to_nil(hash)
          hash.deep_transform_values do |v|
            if v.is_a?(Array)
              v.each do |h|
                convert_all_null_values_to_nil(h)
              end
            else
              v == "NULL" ? nil : v
            end
          end
        end
      end
    end
  end
end
