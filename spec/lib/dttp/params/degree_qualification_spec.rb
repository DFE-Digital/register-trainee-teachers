# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe DegreeQualification do
      let(:contact_change_set_id) { SecureRandom.uuid }
      let(:placement_assignment_change_set_id) { SecureRandom.uuid }

      let(:dttp_degree_grade_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_type_id) { SecureRandom.uuid }
      let(:dttp_degree_institution_entity_id) { SecureRandom.uuid }
      let(:dttp_country_entity_id) { SecureRandom.uuid }

      before do
        stub_const("Dttp::CodeSets::Grades::MAPPING",
                   { degree.grade => { entity_id: dttp_degree_grade_entity_id } })
        stub_const("Dttp::CodeSets::DegreeSubjects::MAPPING",
                   { degree.subject => { entity_id: dttp_degree_subject_entity_id } })
        stub_const("Dttp::CodeSets::DegreeTypes::MAPPING",
                   { degree_type => { entity_id: dttp_degree_type_id } })
        stub_const("Dttp::CodeSets::Institutions::MAPPING",
                   { degree.institution => { entity_id: dttp_degree_institution_entity_id } })
        stub_const("Dttp::CodeSets::Countries::MAPPING",
                   { degree.country => { entity_id: dttp_country_entity_id } })
      end

      subject { described_class.new(degree, contact_change_set_id, placement_assignment_change_set_id).params }

      describe "#params" do
        context "UK degree" do
          let(:degree) { build(:degree, :uk_degree_with_details) }
          let(:degree_type) { degree.uk_degree }

          it "returns a hash with all the UK specific degree qualification fields " do
            expect(subject).to match({
              "dfe_name" => degree.uk_degree,
              "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
              "dfe_TrainingRecordId@odata.bind" => "$#{placement_assignment_change_set_id}",
              "dfe_ClassofDegreeId@odata.bind" => "/dfe_classofdegrees(#{dttp_degree_grade_entity_id})",
              "dfe_DegreeSubjectId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
              "dfe_DegreeTypeId@odata.bind" => "/dfe_degreetypes(#{dttp_degree_type_id})",
              "dfe_AwardingInstitutionId@odata.bind" => "/accounts(#{dttp_degree_institution_entity_id})",
            })
          end
        end

        context "Non-UK degree" do
          let(:degree) { build(:degree, :non_uk_degree_with_details) }
          let(:degree_type) { degree.non_uk_degree_non_naric? ? "Unknown" : "Degree equivalent" }

          it "returns a hash with all the Non-UK specific degree qualification fields" do
            expect(subject).to match({
              "dfe_name" => degree.non_uk_degree,
              "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
              "dfe_TrainingRecordId@odata.bind" => "$#{placement_assignment_change_set_id}",
              "dfe_DegreeSubjectId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
              "dfe_DegreeTypeId@odata.bind" => "/dfe_degreetypes(#{dttp_degree_type_id})",
              "dfe_DegreeCountryId@odata.bind" => "/dfe_countries(#{dttp_country_entity_id})",
            })
          end
        end
      end
    end
  end
end
