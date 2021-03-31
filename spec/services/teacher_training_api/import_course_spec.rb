# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCourse do
    describe "#call" do
      let(:provider) { create(:provider) }
      let(:imported_course) { JSON(ApiStubs::TeacherTrainingApi.course) }
      let(:imported_code) { imported_course["attributes"]["code"] }
      let(:imported_name) { imported_course["attributes"]["name"] }
      let(:imported_subject_codes) { imported_course["attributes"]["subject_codes"] }

      let(:course_subjects) do
        imported_subject_codes.map do |subject_code|
          build(:subject, code: subject_code)
        end
      end

      subject { described_class.call(provider: provider, course: imported_course) }

      before do
        allow(Subject).to receive(:where).with({ code: imported_subject_codes }).and_return(course_subjects)
      end

      context "when the course code does not exist in register" do
        let(:course) { provider.courses.find_by(code: imported_code, name: imported_name) }

        context "and it's non-draft" do
          it "creates the course for the provider with the correct code and name" do
            expect { subject }.to change { provider.courses.count }.by(1)
          end

          it "create a course with the correct code and name" do
            subject
            expect(provider.courses.find_by(code: imported_code, name: imported_name)).to_not be_nil
          end

          it "creates the course with the correct subjects" do
            expect { subject }.to change { CourseSubject.count }.from(0).to(1)
            expect(course.subjects).to match course_subjects
          end

          it "parses the start date" do
            subject
            expect(course.start_date).to be_instance_of(Date)
          end

          it "parses the age range" do
            subject
            expect(course.age_range).to eq(AgeRange::ELEVEN_TO_NINETEEN_COURSE)
          end

          it "parses qualification" do
            subject
            expect(course.qualification).to eq("pgce_with_qts")
          end
        end

        context "course has a further_education level" do
          let(:imported_course) { JSON(ApiStubs::TeacherTrainingApi.course(level: "further_education")) }

          it "doesn't get imported" do
            expect { subject }.to_not(change { Course.count })
          end
        end

        context "and it's draft" do
          let(:imported_course) { JSON(ApiStubs::TeacherTrainingApi.course(state: "draft")) }

          it "does not create the course" do
            expect { subject }.not_to(change { Course.count })
          end

          it "does not create the course_subject join" do
            expect { subject }.not_to(change { CourseSubject.count })
          end
        end
      end

      context "when the course code already exists for that provider" do
        let(:existing_course) do
          create(:course,
                 code: imported_code,
                 provider: provider,

                 name: course_name,
                 subjects: course_subjects)
        end

        let(:course_name) { imported_name }
        before { existing_course }

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
          let(:course_name) { "different name" }

          it "updates the name" do
            subject
            expect(provider.courses.find_by(code: imported_code).name).to eq(imported_name)
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
            expect(provider.courses.find_by(code: imported_code).subjects).to eq course_subjects
          end

          it "does not create duplicate course" do
            expect { subject }.not_to(change { Course.count })
          end

          it "does not create duplicate course subjects" do
            expect { subject }.to_not(change { CourseSubject.count })
          end
        end
      end

      context "when the course code already exists in register, but for a different provider" do
        before { create(:course, code: imported_code) }

        it "creates the course for the new provider" do
          expect { subject }.to change { provider.courses.count }.by(1)
        end
      end
    end
  end
end
