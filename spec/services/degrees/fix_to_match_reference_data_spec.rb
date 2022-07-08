# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe FixToMatchReferenceData do
    let(:institution) { "The Open University" }
    let(:type) { "Foundation of Arts" }
    let(:subject_name) { "English studies" }
    let(:grade) { "First-class honours" }

    subject { described_class.call(degree: degree) }

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

            it "is updated" do
              expect(subject.institution).to eq("University of Chichester")
              expect(subject.institution_uuid).to be(institution_id_for("University of Chichester"))
            end
          end

          context "match isn't found in reference data" do
            let(:institution) { "Chorley Wetherspoons" }

            it "is left unchanged" do
              expect(subject.institution).to eq(institution)
              expect(subject.institution_uuid).to eq(nil)
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

            it "is updated" do
              expect(subject.uk_degree).to eq("Foundation of Arts")
              expect(subject.uk_degree_uuid).to be(type_id_for("Foundation of Arts"))
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
            let(:subject_name) { "English Studies" }

            it "is updated" do
              expect(subject.subject).to eq("English studies")
              expect(subject.subject_uuid).to eq(subject_id_for("English studies"))
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

            it "is updated" do
              expect(subject.grade).to eq("First-class honours")
              expect(subject.grade_uuid).to eq(grade_id_for("First-class honours"))

            end
          end

          context "match isn't found in reference data" do
            let(:grade) { "Epic fail" }

            it "is left unchanged" do
              expect(subject.grade).to eq(grade)
              expect(subject.grade_uuid).to eq(nil)
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

            it "is updated" do
              expect(subject.subject).to eq("English studies")
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

            it "is updated" do
              expect(subject.grade).to eq("First-class honours")
              expect(subject.grade_uuid).to eq(nil)
            end
          end

          context "match isn't found in reference data" do
            let(:grade) { "Epic fail" }

            it "is left unchanged" do
              expect(subject.grade).to eq(grade)
              expect(subject.grade_uuid).to eq(nil)
            end
          end
        end
      end
    end

    def institution_id_for(name)
      DfE::ReferenceData::Degrees::INSTITUTIONS.some({ name: name }).first.id
    end

    def subject_id_for(name)
      DfE::ReferenceData::Degrees::SUBJECTS.some({ name: name }).first.id
    end

    def grade_id_for(name)
      DfE::ReferenceData::Degrees::GRADES.some({ name: name }).first.id
    end

    def type_id_for(name)
      DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS.some({ name: name }).first.id
    end
  end
end
