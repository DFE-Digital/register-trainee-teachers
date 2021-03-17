# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCourse do
    describe "#call" do
      let(:provider) { create(:provider) }
      let(:course) { JSON(ApiStubs::TeacherTrainingApi.course) }
      let(:code) { course["attributes"]["code"] }
      let(:name) { course["attributes"]["name"] }

      subject { described_class.call(provider: provider, course: course) }

      context "when the course code does not exist in register" do
        context "and it's non-draft" do
          it "creates the course for the provider with the correct code and name" do
            expect { subject }.to change { provider.courses.count }.by(1)
          end

          it "create a course with the correct code and name" do
            subject
            expect(provider.courses.find_by(code: code, name: name)).to_not be_nil
          end
        end

        context "and it's draft" do
          let(:course) { JSON(ApiStubs::TeacherTrainingApi.course(state: "draft")) }

          it "does not create the course" do
            expect { subject }.not_to(change { Course.count })
          end
        end
      end

      context "when the course code already exists for that provider" do
        context "with the same name" do
          before { create(:course, code: code, name: name, provider: provider) }

          it "does not creates a duplicate course" do
            expect { subject }.not_to(change { Course.count })
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
