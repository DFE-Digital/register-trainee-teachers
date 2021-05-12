# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCourse do
    describe "#call" do
      let(:course_attributes) { {} }
      let(:course_data) { ApiStubs::TeacherTrainingApi.course(course_attributes) }
      let(:course_code) { course_data[:attributes][:code] }
      let(:course_name) { course_data[:attributes][:name] }
      let(:course_subject_codes) { course_data[:attributes][:subject_codes] }
      let(:provider_data) { [] }

      let(:course_subjects) do
        course_subject_codes.map do |subject_code|
          build(:subject, code: subject_code)
        end
      end

      subject { described_class.call(course_data: course_data, provider_data: provider_data) }

      before do
        allow(Subject).to receive(:where).with({ code: course_subject_codes }).and_return(course_subjects)
      end

      context "when the course code does not exist in register" do
        let(:course) { Course.find_by(code: course_code, name: course_name) }

        context "and it's non-draft" do
          it "creates the course for the provider with the correct code and name" do
            expect { subject }.to change { Course.count }.by(1)
          end

          it "create a course with the correct code and name" do
            subject
            expect(course).to_not be_nil
          end

          it "creates the course with the correct subjects" do
            expect { subject }.to change { CourseSubject.count }.from(0).to(1)
            expect(course.subjects).to match course_subjects
          end

          it "parses the start date" do
            subject
            expect(course.start_date).to be_instance_of(Date)
          end

          it "parses the min and max age" do
            subject
            expect(course.min_age).to eq(course_data[:attributes][:age_minimum])
            expect(course.max_age).to eq(course_data[:attributes][:age_maximum])
          end

          it "parses qualification" do
            subject
            expect(course.qualification).to eq("pgce_with_qts")
          end
        end

        context "course has a further_education level" do
          let(:course_attributes) { { level: "further_education" } }

          it "doesn't get imported" do
            expect { subject }.to_not(change { Course.count })
          end
        end

        context "and it's draft" do
          let(:course_attributes) { { state: "draft" } }

          it "does not create the course" do
            expect { subject }.not_to(change { Course.count })
          end

          it "does not create the course_subject join" do
            expect { subject }.not_to(change { CourseSubject.count })
          end
        end
      end

      context "when the course code already exists for that provider" do
        before { create(:course, code: course_code, name: course_name, subjects: course_subjects) }

        context "with the same name" do
          it "does not create duplicate course" do
            expect { subject }.not_to(change { Course.count })
          end
        end

        context "with the same subjects" do
          it "does not create duplicate course subjects" do
            expect { subject }.to_not(change { CourseSubject.count })
          end
        end

        context "with a different name" do
          let(:course_attributes) { { name: "different name" } }

          it "updates the name" do
            subject
            expect(Course.find_by(code: course_code).name).to eq(course_attributes[:name])
          end

          it "does not create duplicate course" do
            expect { subject }.not_to(change { Course.count })
          end

          it "does not create duplicate course subjects" do
            expect { subject }.to_not(change { CourseSubject.count })
          end
        end

        context "with a different subjects" do
          let(:course_subjects) { [music_subject] }

          let(:music_subject) { create(:subject, :music) }

          it "updates the subjects" do
            subject
            expect(Course.find_by(code: course_code).subjects).to eq course_subjects
          end

          it "does not create duplicate course" do
            expect { subject }.not_to(change { Course.count })
          end

          it "does not create duplicate course subjects" do
            expect { subject }.to_not(change { CourseSubject.count })
          end
        end
      end

      xcontext "when the course code already exists in register, but for a different provider" do
        before { create(:course, code: course_code) }

        it "creates the course for the new provider" do
          expect { subject }.to change { Course.count }.by(1)
        end
      end
    end
  end
end
