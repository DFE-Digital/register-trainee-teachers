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
        sex: "F_SEXID",
        ukprn: "F_UKPRN",
        provider_trainee_id: "F_OWNSTU",
        course_subject_one: "F_SBJCA1",
        course_subject_two: "F_SBJCA2",
        course_subject_three: "F_SBJCA3",
        itt_end_date: "F_EXPECTEDENDDATE",
        employing_school_urn: "F_SDEMPLOY",
        training_partner_urn: "F_SDLEAD",
        mode: "F_MODE",
        course_age_range: "F_ITTPHSC",
        training_initiative: "F_INITIATIVES1",
        hesa_id: "F_HUSID",
        bursary_level: "F_BURSLEV",
        training_route: "F_ENTRYRTE",
        nationality: "F_NATION",
        hesa_updated_at: "F_STATUS_TIMESTAMP",
        itt_aim: "F_ITTAIM",
        itt_qualification_aim: "F_QLAIM",
        fund_code: "F_FUNDCODE",
        course_programme_title: "F_CTITLE",
        pg_apprenticeship_start_date: "F_PGAPPSTDT",
        year_of_course: "F_YEARPRG",
        degrees: "PREVIOUSQUALIFICATIONS",
        placements: "PLACEMENTS",
        disability1: "F_DISABLE1",
        disability2: "F_DISABLE2",
        disability3: "F_DISABLE3",
        disability4: "F_DISABLE4",
        disability5: "F_DISABLE5",
        disability6: "F_DISABLE6",
        disability7: "F_DISABLE7",
        disability8: "F_DISABLE8",
        disability9: "F_DISABLE9",
        itt_key: "F_ITTKEY",
        rec_id: "F_RECID",
        status: "F_STATUS",
        allocated_place: "F_ALLPLACE",
        provider_course_id: "F_COURSEID",
        initiatives_two: "F_INITIATIVES2",
        ni_number: "F_NIN",
        numhus: "F_NUMHUS",
        previous_surname: "F_PSURNAME",
        surname16: "F_SNAME16",
        ttcid: "F_TTCID",
        hesa_committed_at: "F_COMMIT_TIMESTAMP",
        application_choice_id: "F_APPLYAPPLICATIONID",
        itt_start_date: "F_ITTSTARTDATE",
        trainee_start_date: "F_TRAINEESTARTDATE",
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
              subject_one: qualification["F_DEGSBJ1"],
              subject_two: qualification["F_DEGSBJ2"],
              subject_three: qualification["F_DEGSBJ3"],
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
              v&.downcase == "null" ? nil : v
            end
          end
        end
      end
    end
  end
end
