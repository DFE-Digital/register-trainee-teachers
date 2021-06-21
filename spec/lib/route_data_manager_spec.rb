# frozen_string_literal: true

require "rails_helper"

describe RouteDataManager do
  subject { described_class.new(trainee: trainee) }

  describe "#update_training_route" do
    context "when a trainee selects a new route" do
      context "when a trainee has course details" do
        let(:trainee) { create(:trainee, :assessment_only, :with_course_details) }

        it "wipes the course details and changes route" do
          expect { subject.update_training_route!("provider_led_postgrad") }
            .to change { trainee.progress.course_details }
            .from(trainee.progress.course_details).to(false)
            .and change { trainee.course_code }
            .from(trainee.course_code).to(nil)
            .and change { trainee.course_subject_one }
            .from(trainee.course_subject_one).to(nil)
            .and change { trainee.course_age_range }
            .from(trainee.course_age_range).to([])
            .and change { trainee.course_start_date }
            .from(trainee.course_start_date).to(nil)
            .and change { trainee.course_end_date }
            .from(trainee.course_end_date).to(nil)
            .and change { trainee.training_route }
            .from(trainee.training_route).to("provider_led_postgrad")
        end
      end
    end

    context "when a trainee selects the same route" do
      context "when a trainee has course details" do
        let(:trainee) { create(:trainee, :provider_led_postgrad, :with_course_details) }

        before do
          subject.update_training_route!("provider_led_postgrad")
          trainee.reload
        end

        it "does not clear the course details section of the trainee" do
          expect(trainee.course_code).to be_present
          expect(trainee.course_subject_one).to be_present
          expect(trainee.course_age_range).to be_present
          expect(trainee.course_start_date).to be_present
          expect(trainee.course_end_date).to be_present
        end
      end
    end
  end
end
