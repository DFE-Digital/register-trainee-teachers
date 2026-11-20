# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    RSpec.describe V20270::ImportRow, time_sensitive: true do
      let(:current_provider) { create(:provider) }
      let!(:nationality) { create(:nationality, :british) }
      let(:academic_cycle) { AcademicCycle.for_year(2027) || create(:academic_cycle, cycle_year: 2027) }
      let(:allocation_subject) { create(:allocation_subject) }
      let(:degree_subject) { "100417" }
      let(:result) { described_class.call(row:, current_provider:) }

      let(:row_values) do
        {
          "provider_trainee_id" => "27/28-1",
          "hesa_id" => "7572897115906",
          "first_names" => "Spencer",
          "last_name" => "Murphy",
          "date_of_birth" => "1990-01-01",
          "sex" => "11",
          "email" => "spencer.murphy@example.com",
          "nationality" => "GB",
          "itt_aim" => "202",
          "training_route" => Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]],
          "itt_qualification_aim" => "001",
          "course_subject_1" => Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::CHEMISTRY],
          "study_mode" => Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
          "itt_start_date" => "2027-09-01",
          "itt_end_date" => "2028-07-31",
          "course_age_range" => "13918",
          "course_year" => "2027",
          "trainee_start_date" => "2027-09-01",
          "fund_code" => Hesa::CodeSets::FundCodes::ELIGIBLE,
          "funding_method" => Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
          "uk_degree" => "083",
          "degree_subject" => degree_subject,
          "degree_grade" => "02",
          "degree_graduation_year" => "2003-07-01",
          "awarding_institution" => "0117",
        }
      end
      let(:row) { CSV::Row.new(row_values.keys, row_values.values) }

      before do
        stub_const("BulkUpdate::AddTrainees::Config::VERSION", "v2027.0")

        create(:subject_specialism, allocation_subject: allocation_subject, name: CourseSubjects::CHEMISTRY)
        funding_rule = create(
          :funding_method,
          training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
          funding_type: FUNDING_TYPE_ENUMS[:bursary],
          academic_cycle: academic_cycle,
          degree_relevance: "relevant",
        )
        create(:funding_method_subject, funding_method: funding_rule, allocation_subject: allocation_subject)
        create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: allocation_subject, hecos_code: "100417")
      end

      describe "#call" do
        context "when the bursary is only for a relevant degree" do
          context "with a relevant degree" do
            it "creates a trainee record with a bursary" do
              expect { result }.to change { Trainee.count }.by(1)

              expect(result.success).to be(true)
              expect(Trainee.last.applying_for_bursary).to be(true)
            end
          end

          context "with an unrelated degree" do
            let(:degree_subject) { "100302" }

            it "does not create a trainee record and returns the funding error" do
              expect { result }.not_to change { Trainee.count }

              expect(result.success).to be(false)
              expect(result.errors).to include(
                a_string_including("'bursary' is not allowed when training_route is 'provider_led_postgrad' and course_subject_1 is 'chemistry' in academic cycle '2027 to 2028'"),
              )
            end
          end
        end
      end
    end
  end
end
