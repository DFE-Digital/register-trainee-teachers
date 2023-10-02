# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe MapFromApply do
    let(:degree_subject) { "Accountancy" }
    let(:degree_grade) { "First-class honours" }
    let(:degree_qualification_type) { "Bachelor of Accountancy" }
    let(:degree_institution) { "The Open University" }
    let(:degree_attributes) { JSON.parse(application_data).dig("attributes", "qualifications", "degrees").first }

    let(:application_data) do
      ApiStubs::RecruitsApi.application(degree_attributes: {
        subject: dfe_degree_subject_reference_data[:name],
        hesa_degsbj: dfe_degree_subject_reference_data[:hecos_code],
        grade: dfe_degree_grade_reference_data[:name],
        hesa_degclss: dfe_degree_grade_reference_data[:hesa_itt_code],
        qualification_type: dfe_degree_type_reference_data[:abbreviation],
        hesa_degtype: dfe_degree_type_reference_data[:hesa_itt_code],
        institution_details: dfe_degree_institution_reference_data[:name],
        hesa_degest: dfe_degree_institution_reference_data[:hesa_itt_code],
      })
    end

    let(:dfe_degree_type_reference_data) do
      DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS.some(name: degree_qualification_type).first
    end

    let(:dfe_degree_subject_reference_data) do
      DfE::ReferenceData::Degrees::SINGLE_SUBJECTS.some(name: degree_subject).first
    end

    let(:dfe_degree_grade_reference_data) do
      DfE::ReferenceData::Degrees::GRADES.some(name: degree_grade).first
    end

    let(:dfe_degree_institution_reference_data) do
      DfE::ReferenceData::Degrees::INSTITUTIONS.some(name: degree_institution).first
    end

    let(:common_attributes) do
      {
        is_apply_import: true,
        subject: dfe_degree_subject_reference_data[:name],
        subject_uuid: dfe_degree_subject_reference_data[:id],
        graduation_year: degree_attributes["award_year"],
      }
    end

    subject { described_class.call(attributes: degree_attributes) }

    it { is_expected.to be_a(Hash) }
    it { is_expected.to include(common_attributes) }

    context "with a uk degree" do
      let(:expected_uk_degree_attributes) do
        {
          locale_code: Degree.locale_codes[:uk],
          uk_degree: dfe_degree_type_reference_data[:name],
          uk_degree_uuid: dfe_degree_type_reference_data[:id],
          institution: dfe_degree_institution_reference_data[:name],
          institution_uuid: dfe_degree_institution_reference_data[:id],
          grade: dfe_degree_grade_reference_data[:name],
          grade_uuid: dfe_degree_grade_reference_data[:id],
        }
      end

      it { is_expected.to include(expected_uk_degree_attributes) }

      context "HESA codes are not present" do
        let(:application_data) do
          ApiStubs::RecruitsApi.application(degree_attributes: {
            uk_degree: dfe_degree_type_reference_data[:name],
            subject: dfe_degree_subject_reference_data[:name],
            grade: dfe_degree_grade_reference_data[:name],
            qualification_type: dfe_degree_type_reference_data[:abbreviation],
            institution_details: dfe_degree_institution_reference_data[:name],
          })
        end

        it { is_expected.to include(expected_uk_degree_attributes) }
      end

      context "unrecognised grade" do
        let(:unrecognised_grade) { "Balloney" }

        let(:application_data) do
          ApiStubs::RecruitsApi.application(degree_attributes: {
            grade: unrecognised_grade,
            grade_uuid: nil,
            hesa_degclss: nil,
          })
        end

        it "stores the other grade" do
          expect(subject).to include(grade: "Other",
                                     other_grade: unrecognised_grade)
        end
      end

      context "degree country, comparable_uk_degree and non_uk_qualification_type are nil" do
        let(:uk_degree) { "Bachelor of Arts" }

        let(:application_data) do
          ApiStubs::RecruitsApi.application(degree_attributes: {
            hesa_degctry: nil,
            comparable_uk_degree: nil,
            non_uk_qualification_type: nil,
          })
        end

        it "sets degree to uk" do
          expect(subject).to include(uk_degree:)
        end
      end
    end

    context "with a non-uk degree" do
      let(:application_data) do
        ApiStubs::RecruitsApi.non_uk_application(degree_attributes: { subject: degree_subject }).to_json
      end

      let(:expected_non_uk_degree_attributes) do
        {
          locale_code: Degree.locale_codes[:non_uk],
          country: "St Kitts and Nevis",
          non_uk_degree: degree_attributes["comparable_uk_degree"],
        }
      end

      it { is_expected.to include(expected_non_uk_degree_attributes) }

      context "degree country is nil but comparable_uk_degree exists" do
        let(:application_data) do
          ApiStubs::RecruitsApi.non_uk_application(degree_attributes: {
            hesa_degctry: nil,
            non_uk_qualification_type: nil,
          }).to_json
        end

        let(:expected_non_uk_degree_attributes) do
          {
            locale_code: Degree.locale_codes[:non_uk],
            non_uk_degree: degree_attributes["comparable_uk_degree"],
          }
        end

        it "sets correct locale_code and non_uk_degree" do
          expect(subject).to include(expected_non_uk_degree_attributes)
        end
      end
    end
  end
end
