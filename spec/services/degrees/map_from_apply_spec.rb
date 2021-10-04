# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe MapFromApply do
    let(:application_data) { ApiStubs::ApplyApi.application }
    let(:apply_application) { create(:apply_application, application: application_data) }
    let(:degree_attributes) { JSON.parse(application_data).dig("attributes", "qualifications", "degrees").first }
    let(:expected_subject) { degree_attributes["subject"] }

    let(:common_attributes) do
      {
        is_apply_import: true,
        subject: expected_subject,
        graduation_year: degree_attributes["award_year"],
      }
    end

    subject { described_class.call(attributes: degree_attributes) }

    it { is_expected.to be_a(Hash) }
    it { is_expected.to include(common_attributes) }

    context "with a uk degree" do
      let(:expected_institution) { degree_attributes["institution_details"] }
      let(:expected_uk_degree) { Dttp::CodeSets::DegreeTypes::BACHELOR_OF_ARTS }
      let(:expected_grade) { Dttp::CodeSets::Grades::FIRST_CLASS_HONOURS }

      let(:expected_uk_degree_attributes) do
        {
          locale_code: Trainee.locale_codes[:uk],
          uk_degree: expected_uk_degree,
          institution: expected_institution,
          grade: expected_grade,
        }
      end

      context "institution" do
        let(:expected_institution) { "The University of Love" }
        let(:stub_institution_mapping) { { expected_institution => { entity_id: "1", hesa_code: "1" } } }

        let(:application_data) do
          ApiStubs::ApplyApi.application(degree_attributes: { hesa_degest: "0001" })
        end

        before do
          stub_const("Dttp::CodeSets::Institutions::MAPPING", stub_institution_mapping)
        end

        it { is_expected.to include(expected_uk_degree_attributes) }
      end

      context "subject" do
        let(:expected_subject) { "Art of charm" }
        let(:stub_subject_mapping) { { expected_subject => { entity_id: "1" } } }

        let(:application_data) do
          ApiStubs::ApplyApi.application(degree_attributes: { subject: "art Of ChaRm" })
        end

        before do
          stub_const("Dttp::CodeSets::DegreeSubjects::MAPPING", stub_subject_mapping)
        end

        it { is_expected.to include(expected_uk_degree_attributes) }
      end

      context "degree type" do
        let(:stub_degree_type_mapping) do
          {
            "Bachelor of Charm" => { entity_id: "1", abbreviation: "BAc", hesa_code: "1" },
            "Doctor of Love" => { entity_id: "2", abbreviation: "BAs", hesa_code: "2" },
          }
        end

        before do
          stub_const("Dttp::CodeSets::DegreeTypes::MAPPING", stub_degree_type_mapping)
        end

        context "with hesa code" do
          let(:expected_uk_degree) { "Bachelor of Charm" }

          let(:application_data) do
            ApiStubs::ApplyApi.application(degree_attributes: { hesa_degtype: "0001" })
          end

          it { is_expected.to include(expected_uk_degree_attributes) }
        end

        context "with abbreviation" do
          let(:expected_uk_degree) { "Doctor of Love" }

          let(:application_data) do
            ApiStubs::ApplyApi.application(degree_attributes: { qualification_type: "BAs" })
          end

          it { is_expected.to include(expected_uk_degree_attributes) }
        end
      end

      context "grade" do
        let(:expected_grade) { Dttp::CodeSets::Grades::FIRST_CLASS_HONOURS }

        context "with hesa code" do
          let(:application_data) do
            ApiStubs::ApplyApi.application(degree_attributes: { hesa_degclss: "01", grade: "First class honours" })
          end

          it "sets the value to the actual grade" do
            expect(subject).to include(
              expected_uk_degree_attributes.merge(other_grade: nil),
            )
          end
        end

        context "when the grade is predicted" do
          let(:application_data) do
            ApiStubs::ApplyApi.application(degree_attributes: { hesa_degclss: nil, grade: grade })
          end

          context "first-class honours" do
            let(:grade) { "First class honours (Predicted)" }

            it "sets the value to the actual grade" do
              expect(subject).to include(expected_uk_degree_attributes.merge(other_grade: nil))
            end
          end

          context "second-class honours" do
            let(:expected_grade) { Dttp::CodeSets::Grades::UPPER_SECOND_CLASS_HONOURS }
            let(:grade) { "Upper second-class honours (2:1)(2:1(predicted)" }

            it "sets the value to the actual grade" do
              expect(subject).to include(expected_uk_degree_attributes.merge(other_grade: nil))
            end
          end
        end

        context "when the grade can't be found" do
          let(:expected_grade) { Dttp::CodeSets::Grades::OTHER }

          let(:application_data) do
            ApiStubs::ApplyApi.application(degree_attributes: { hesa_degclss: nil, grade: "merit" })
          end

          it "sets the value to other" do
            expect(subject).to include(
              expected_uk_degree_attributes.merge(other_grade: degree_attributes["grade"]),
            )
          end
        end
      end

      it { is_expected.to include(expected_uk_degree_attributes) }
    end

    context "with a non-uk degree" do
      let(:non_uk_degree_attributes) do
        {
          locale_code: Trainee.locale_codes[:non_uk],
          non_uk_degree: degree_attributes["comparable_uk_degree"],
          country: "St Kitts and Nevis",
        }
      end

      let(:degree_attributes) { ApiStubs::ApplyApi.non_uk_degree.as_json }

      it { is_expected.to include(non_uk_degree_attributes) }
    end
  end
end
