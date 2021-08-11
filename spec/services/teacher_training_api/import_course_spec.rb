# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCourse do
    describe "#call" do
      let(:course_attributes) { { subject_codes: %w[C6 BW] } }
      let(:course_data) { ApiStubs::TeacherTrainingApi.course(course_attributes) }
      let(:course_code) { course_data[:attributes][:code] }
      let(:course_name) { course_data[:attributes][:name] }
      let(:accredited_body_code) { course_data[:attributes][:accredited_body_code] }
      let(:course_subject_codes) { course_data[:attributes][:subject_codes] }
      let(:course) { Course.find_by(code: course_code, accredited_body_code: accredited_body_code) }

      before do
        # Using reverse() to test ordering of course.subjects matches the order of course_subject_codes
        course_subject_codes.reverse.map do |subject_code|
          create(:subject, code: subject_code)
        end
      end

      subject { described_class.call(course_data: course_data, provider_data: {}) }

      context "when the course code does not exist in register" do
        context "and it's non-draft" do
          before { subject }

          it "create a course with the name" do
            expect(course.name).to eq(course_name)
          end

          it "create a course with the correct code" do
            expect(course.code).to eq(course_code)
          end

          it "create a course with the correct accredited_body_code" do
            expect(course.accredited_body_code).to eq(accredited_body_code)
          end

          it "creates the course with subjects in the exact order they come from the API" do
            expect(course.subjects.pluck(:code)).to eq(course_subject_codes)
          end

          it "parses the start date" do
            expect(course.start_date).to be_instance_of(Date)
          end

          it "parses the min and max age" do
            expect(course.min_age).to eq(course_data[:attributes][:age_minimum])
            expect(course.max_age).to eq(course_data[:attributes][:age_maximum])
          end

          it "parses qualification" do
            expect(course.qualification).to eq("pgce_with_qts")
          end
        end

        context "course has a further_education level" do
          let(:course_attributes) { { level: "further_education" } }

          it "doesn't get imported" do
            expect { subject }.not_to(change { Course.count })
          end
        end

        context "course has an invalid age range" do
          let(:course_attributes) { { age_minimum: nil } }

          it "doesn't get imported" do
            expect { subject }.not_to(change { Course.count })
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

      context "when the course with subjects already exists for that provider" do
        before do
          create(:course_with_subjects, code: course_code, accredited_body_code: accredited_body_code)
        end

        context "with a different name" do
          let(:course_attributes) { { name: "different name" } }

          it "updates the name" do
            subject
            expect(course.name).to eq(course_attributes[:name])
          end

          it "does not create duplicate course" do
            expect { subject }.not_to(change { Course.count })
          end
        end

        context "with a different subject" do
          let(:subject_code) { "CW" }
          let(:course_attributes) { { subject_codes: [subject_code] } }

          it "updates the subjects" do
            subject
            expect(course.subjects.pluck(:code)).to eq([subject_code])
          end

          it "does not create duplicate course subjects" do
            expect { subject }.not_to(change { Subject.count })
          end
        end
      end

      context "same course, different provider" do
        before { create(:course, code: course_code) }

        it "creates the course for the provider" do
          expect { subject }.to change { Course.count }.by(1)
        end
      end
    end
  end
end
