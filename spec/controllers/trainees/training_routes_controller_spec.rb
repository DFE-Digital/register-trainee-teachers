# frozen_string_literal: true

require "rails_helper"

describe Trainees::TrainingRoutesController do
  let(:user) { build(:user, provider: trainee.provider) }
  let(:trainee_params) { { training_route: :provider_led_postgrad } }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#update" do
    subject { post(:update, params: { trainee_id: trainee.slug, trainee: trainee_params }) }

    context "when changing to a new route" do
      context "with a completed course details section" do
        let(:trainee) { create(:trainee, :assessment_only, :with_course_details) }

        it "clears the course details section of the trainee" do
          subject
          trainee.reload
          expect(trainee.progress.course_details).to eq false
          expect(trainee.course_code).to eq nil
          expect(trainee.subject).to eq nil
          expect(trainee.subject_two).to eq nil
          expect(trainee.subject_three).to eq nil
          expect(trainee.course_age_range).to eq []
          expect(trainee.course_start_date).to eq nil
          expect(trainee.course_end_date).to eq nil
        end
      end
    end

    context "when changing to the same route" do
      context "with a completed course details section" do
        let(:trainee) { create(:trainee, :provider_led_postgrad, :with_course_details) }

        it "clears the course details section of the trainee" do
          subject
          trainee.reload
          expect(trainee.progress.course_details).to eq nil
          expect(trainee.course_code).to eq trainee.course_code
          expect(trainee.subject).to eq trainee.subject
          expect(trainee.subject_two).to eq trainee.subject_two
          expect(trainee.subject_three).to eq trainee.subject_three
          expect(trainee.course_age_range).to eq trainee.course_age_range
          expect(trainee.course_start_date).to eq trainee.course_start_date
          expect(trainee.course_end_date).to eq trainee.course_end_date
        end
      end
    end
  end
end
