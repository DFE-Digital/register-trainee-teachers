# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCourse do
    describe "#call" do
      let(:provider) { create(:provider) }
      let(:course) { JSON(ApiStubs::TeacherTrainingApi.course) }
      let(:code) { course["attributes"]["code"] }
      let(:name) { course["attributes"]["name"] }
      let(:subject_codes) { course["attributes"]["subject_codes"] }
      let(:subject_object) { build(:subject, code: subject_codes.first) }
      subject { described_class.call(provider: provider, course: course) }

      before do
        allow(Subject).to receive(:where).with({ code: subject_codes }).and_return([subject_object])
      end

      context "when the course code does not exist in register" do
        context "and it's non-draft" do
          it "creates the course for the provider with the correct code and name" do
            expect { subject }.to change { provider.courses.count }.by(1)
          end

          it "create a course with the correct code and name" do
            subject
            expect(provider.courses.find_by(code: code, name: name)).to_not be_nil
          end

          it "creates the course with the correct subjects" do
            expect { subject }.to change { CourseSubject.count }.from(0).to(1)
            expect(provider.courses.find_by(code: code, name: name).subjects).to match [subject_object]
          end
        end

        context "and it's draft" do
          let(:course) { JSON(ApiStubs::TeacherTrainingApi.course(state: "draft")) }

          it "does not create the course" do
            expect { subject }.not_to(change { Course.count })
          end

          it "does not create the course_subject join" do
            expect { subject }.not_to(change { CourseSubject.count })
          end
        end
      end

      context "when the course code already exists for that provider" do
        context "with the same name" do
          before { create(:course, code: code, name: name, provider: provider) }

          it "does not creates a duplicate course" do
            expect { subject }.not_to(change { Course.count })
          end

          it "does not create a duplicate course_subject join" do
            subject
            expect { subject }.not_to(change { CourseSubject.count })
          end
        end

        context "with a different name" do
          before { create(:course, code: code, provider: provider) }

          it "updates the name" do
            subject
            expect(provider.courses.find_by(code: code).name).to eq name
          end
        end
      end

      context "when the course code already exists in register, but for a different provider" do
        before { create(:course, code: code) }

        it "creates the course for the new provider" do
          expect { subject }.to change { provider.courses.count }.by(1)
        end
      end
    end
  end
end
