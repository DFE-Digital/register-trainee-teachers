# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe FixToMatchReferenceData do
    let(:institution) { "The Open University" }
    let(:type) { "Foundation of Arts" }
    let(:subject_name) { "English studies" }
    let(:grade) { "First-class honours" }

    subject { described_class.call(degree:) }

    context "uk degree" do
      let(:degree) { create(:degree, institution: institution, uk_degree: type, subject: subject_name, grade: grade) }

      describe "institution" do
        context "value is correct" do
          it "is left unchanged" do
            expect(subject).to eq(degree)
          end
        end

        context "value is incorrect" do
          context "match is found in reference data" do
            let(:institution) { "The University of Chichester" }

            it "updates the value" do
              expect(subject.institution).to eq("University of Chichester")
            end

            it "updates the UUID" do
              expect(subject.institution_uuid).to eq("0a71f34a-2887-e711-80d8-005056ac45bb")
            end
          end

          context "match isn't found in reference data" do
            let(:institution) { "Chorley Wetherspoons" }

            it "is left unchanged" do
              expect(subject.institution).to eq(institution)
            end
          end
        end
      end

      describe "type" do
        context "value is correct" do
          it "is left unchanged" do
            expect(subject).to eq(degree)
          end
        end

        context "value is incorrect" do
          context "match is found in reference data with different casing" do
            let(:type) { "Foundation of arts" }

            it "updates the value" do
              expect(subject.uk_degree).to eq("Foundation of Arts")
            end

            it "sets the UUID" do
              expect(subject.uk_degree_uuid).to eq("7022c4c2-ec9a-4eec-98dc-315bfeb1ef3a")
            end
          end

          context "match is found in reference data by abbreviation" do
            let(:type) { "MChem" }

            it "updates the value" do
              expect(subject.uk_degree).to eq("Master of Chemistry")
            end

            it "sets the UUID" do
              expect(subject.uk_degree_uuid).to eq("576a5652-c197-e711-80d8-005056ac45bb")
            end
          end

          context "match is present in the generic types" do
            let(:type) { "Degree equivalent" }

            it "updates the value" do
              expect(subject.uk_degree).to eq("Degree equivalent")
            end

            it "sets the UUID" do
              expect(subject.uk_degree_uuid).to eq("03c4fa67-345e-4d09-8e9b-68c36a450947")
            end
          end

          context "match isn't found in reference data" do
            let(:type) { "Dodgy qualification off of the intewebs" }

            it "is left unchanged" do
              expect(subject.uk_degree).to eq(type)
            end
          end
        end
      end

      describe "subject" do
        context "value is correct" do
          it "is left unchanged" do
            expect(subject).to eq(degree)
          end
        end

        context "value is incorrect" do
          context "match is found in reference data with different casing" do
            let(:subject_name) { "Medical Sciences" }

            it "is updates the value" do
              expect(subject.subject).to eq("Medical sciences")
            end

            it "updates the UUID" do
              expect(subject.subject_uuid).to eq("8d8070f0-5dce-e911-a985-000d3ab79618")
            end
          end

          context "match isn't found in reference data" do
            let(:subject_name) { "Harry Styles studies" }

            it "is left unchanged" do
              expect(subject.subject).to eq(subject_name)
            end
          end
        end
      end

      describe "grade" do
        context "value is correct" do
          it "is left unchanged" do
            expect(subject).to eq(degree)
          end
        end

        context "value is incorrect" do
          context "match is found in reference data" do
            let(:grade) { "First class honours" }

            it "is updates the value" do
              expect(subject.grade).to eq("First-class honours")
            end

            it "updates the UUID" do
              expect(subject.grade_uuid).to eq("8741765a-13d8-4550-a413-c5a860a59d25")
            end
          end

          context "match isn't found in reference data" do
            let(:grade) { "Epic fail" }

            it "is left unchanged" do
              expect(subject.grade).to eq(grade)
            end
          end
        end
      end
    end

    context "non uk degree" do
      let(:degree) { create(:degree, :non_uk, institution: nil, subject: subject_name, grade: grade) }

      describe "subject" do
        context "value is correct" do
          it "is left unchanged" do
            expect(subject).to eq(degree)
          end
        end

        context "value is incorrect" do
          context "match is found in reference data with different casing" do
            let(:subject_name) { "English Studies" }

            it "is updates the value" do
              expect(subject.subject).to eq("English studies")
            end

            it "updates the UUID" do
              expect(subject.subject_uuid).to eq("e18070f0-5dce-e911-a985-000d3ab79618")
            end
          end

          context "match isn't found in reference data" do
            let(:subject_name) { "Harry Styles studies" }

            it "is left unchanged" do
              expect(subject.subject).to eq(subject_name)
            end
          end
        end
      end

      describe "grade" do
        context "value is correct" do
          it "is left unchanged" do
            expect(subject).to eq(degree)
          end
        end

        context "value is incorrect" do
          context "match is found in reference data" do
            let(:grade) { "First class honours" }

            it "updates the value" do
              expect(subject.grade).to eq("First-class honours")
            end

            it "updates the UUID" do
              expect(subject.grade_uuid).to eq("8741765a-13d8-4550-a413-c5a860a59d25")
            end
          end

          context "match isn't found in reference data" do
            let(:grade) { "Epic fail" }

            it "is left unchanged" do
              expect(subject.grade).to eq(grade)
            end
          end
        end
      end
    end
  end
end
