# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCourse do
    describe "#call" do
      let(:course_attributes) { { subject_codes: %w[C6 BW] } }
      let(:course_data) { ApiStubs::TeacherTrainingApi.course(course_attributes) }
      let(:course_code) { course_data[:attributes][:code] }
      let(:course_uuid) { course_data[:attributes][:uuid] }
      let(:course_name) { course_data[:attributes][:name] }
      let(:accredited_body_code) { course_data[:attributes][:accredited_body_code] }
      let(:course_subject_codes) { course_data[:attributes][:subject_codes] }
      let(:course) { Course.find_by(uuid: course_uuid) }

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
            expect(course.published_start_date).to be_instance_of(Date)
          end

          it "parses the min and max age" do
            expect(course.min_age).to eq(course_data[:attributes][:age_minimum])
            expect(course.max_age).to eq(course_data[:attributes][:age_maximum])
          end

          it "parses qualification" do
            expect(course.qualification).to eq("pgce_with_qts")
          end

          it "stores the uuid" do
            expect(course.uuid).to eq(course_uuid)
          end

          it "stores the recruitment cycle year" do
            expect(course.recruitment_cycle_year).to eq(Settings.current_recruitment_cycle_year)
          end
        end

        describe "store training route" do
          training_route_and_course_program_type_mapping = "training_route and course program type mapping"
          training_route_and_degree_type_mapping = "training_route_and degree type mapping"

          shared_examples training_route_and_course_program_type_mapping do |recruitment_cycle_year, training_route, program_types|
            before do
              allow(Settings).to receive(:current_recruitment_cycle_year).and_return(recruitment_cycle_year)
            end

            program_types.each do |program_type|
              context "program type #{program_type} is mapped to route #{training_route} for current recruitment cycle year #{recruitment_cycle_year}" do
                let(:course_attributes) { { program_type: } }

                it "stores training route" do
                  subject
                  expect(course.route).to eq(training_route)
                end
              end
            end
          end

          shared_examples training_route_and_degree_type_mapping do |recruitment_cycle_year, training_route, course_training_route, degree_types|
            before do
              allow(Settings).to receive(:current_recruitment_cycle_year).and_return(recruitment_cycle_year)
            end

            degree_types.each do |degree_type|
              context "course training route #{course_training_route} with degree type #{degree_type} is mapped to route #{training_route} for current recruitment cycle year #{recruitment_cycle_year}" do
                let(:course_attributes) { { degree_type: degree_type, training_route: course_training_route } }

                it "stores training route" do
                  subject
                  expect(course.route).to eq(training_route)
                end
              end
            end
          end

          it_behaves_like training_route_and_degree_type_mapping, 2025, "school_direct_salaried", "school_direct_salaried", %w[postgraduate undergraduate]
          it_behaves_like training_route_and_degree_type_mapping, 2025, "teacher_degree_apprenticeship", "teacher_degree_apprenticeship", %w[postgraduate undergraduate]
          it_behaves_like training_route_and_degree_type_mapping, 2025, "pg_teaching_apprenticeship", "postgraduate_teacher_apprenticeship", %w[postgraduate undergraduate]
          it_behaves_like training_route_and_degree_type_mapping, 2025, "provider_led_postgrad", "fee_funded_initial_teacher_training", ["postgraduate"]
          it_behaves_like training_route_and_degree_type_mapping, 2025, "provider_led_undergrad", "fee_funded_initial_teacher_training", ["undergraduate"]
          it_behaves_like training_route_and_course_program_type_mapping, 2024, "school_direct_salaried", %w[scitt_salaried_programme scitt_salaried_programme higher_education_salaried_programme]
          it_behaves_like training_route_and_course_program_type_mapping, 2024, "provider_led_postgrad", %w[scitt_programme scitt_programme higher_education_programme]
          it_behaves_like training_route_and_course_program_type_mapping, 2024, "pg_teaching_apprenticeship", ["pg_teaching_apprenticeship"]

          context "training_route is unmapped" do
            let(:course_attributes) { { training_route: "you_wat_now" } }

            it "raises validation error" do
              expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
            end
          end
        end

        context "course level is primary but max age is greater than 11" do
          let(:course_attributes) { { level: "primary", max_age: 16 } }

          it "doesn't set the age range (provider will have to do it manually to ensure correct values)" do
            expect(subject).to have_attributes(min_age: nil, max_age: nil)
          end
        end

        context "course has a further_education level" do
          let(:course_attributes) { { level: "further_education" } }

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
          create(:course_with_subjects, uuid: course_uuid, code: course_code, accredited_body_code: accredited_body_code)
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
