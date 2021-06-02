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

    context "when changing to the same route" do
      context "with a completed course details section" do
        let(:trainee) { create(:trainee, :provider_led_postgrad, :with_course_details) }

        it "does not clear the course details section of the trainee" do
          subject
          trainee.reload
          expect(trainee.course_code).to be_present
          expect(trainee.subject).to be_present
          expect(trainee.course_age_range).to be_present
          expect(trainee.course_start_date).to be_present
          expect(trainee.course_end_date).to be_present
        end
      end
    end
  end
end
