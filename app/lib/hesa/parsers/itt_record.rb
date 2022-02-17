# frozen_string_literal: true

module Hesa
  module Parsers
    class IttRecord
      class << self
        def to_attributes(student_node:)
          student_attributes = Hash.from_xml(student_node.to_s)["Student"]
          student_attributes = convert_all_null_values_to_nil(student_attributes)

          {
            first_names: student_attributes["F_FNAMES"],
            last_name: student_attributes["F_PSURNAME"],
            email: student_attributes["F_NQTEMAIL"],
            date_of_birth: student_attributes["F_BIRTHDTE"],
            ethnic_background: student_attributes["F_ETHNIC"],
            gender: student_attributes["F_SEXID"],
            ukprn: student_attributes["F_UKPRN"],
            trainee_id: student_attributes["F_OWNSTU"],
            course_subject_one: student_attributes["F_SBJCA1"],
            course_subject_two: student_attributes["F_SBJCA2"],
            course_subject_three: student_attributes["F_SBJCA3"],
            itt_start_date: student_attributes["F_COMDATE"],
            itt_end_date: student_attributes["F_ENDDATE"],
            employing_school_id: student_attributes["F_SDEMPLOY"],
            lead_school_id: student_attributes["F_SDLEAD"],
            study_mode: student_attributes["F_CRMODE"],
            course_age_range: student_attributes["F_ITTPHSC"],
            commencement_date: student_attributes["F_ITTCOMDATE"],
            training_initiative: student_attributes["F_INITIATIVES1"],
            hesa_id: student_attributes["F_HUSID"],
            applying_for_bursary: student_attributes["F_FUNDCODE"],
            international_address: student_attributes["F_DOMICILE"],
            disability: student_attributes["F_DISABLE"],
            end_date: student_attributes["F_ENDDATE"],
            reason_for_leaving: student_attributes["F_RSNEND"],
            bursary_tier: student_attributes["F_BURSLEV"],
            trn: student_attributes["F_TREFNO"],
            training_route: student_attributes["F_ENTRYRTE"],
            nationality: student_attributes["F_NATION"],
            degrees: to_degrees_attributes(student_attributes["PREVIOUSQUALIFICATIONS"]),
          }
        end

        def to_degrees_attributes(qualifications)
          # If there's only one qualification, we get a hash. If there's more
          # than one, we get an array of hashes. Hence the need to wrap and
          # flatten to cover both cases.
          [qualifications.values].flatten.map do |qualification|
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

        def convert_all_null_values_to_nil(hash)
          hash.transform_values do |v|
            if v.is_a?(Hash)
              convert_all_null_values_to_nil(v)
            else
              v == "NULL" ? nil : v
            end
          end
        end
      end
    end
  end
end
