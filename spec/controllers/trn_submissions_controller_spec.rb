# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionsController do
  include ActiveJob::TestHelper

  describe "#create" do
    let(:current_user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    context "when all sections are completed" do
      context "and the course start date is in the future" do
        let(:trainee) do
          create(
            :trainee,
            :completed,
            :with_study_mode_and_future_course_dates,
            provider: current_user.provider,
          )
        end

        it "calls the SubmitForTrn service" do
          expect(Trainees::SubmitForTrn).to receive(:call).with({ trainee: trainee, dttp_id: current_user.dttp_id })
          post :create, params: { trainee_id: trainee }
        end
      end

      context "and the course start date is in the past" do
        let(:trainee) { create(:trainee, :completed, provider: current_user.provider) }

        it "redirects to the trainee start status page" do
          expect(post(:create, params: { trainee_id: trainee }))
            .to redirect_to(edit_trainee_start_status_path(trainee))
        end

        it "does not call the SubmitForTrn service" do
          expect(Trainees::SubmitForTrn).not_to receive(:call)
          post :create, params: { trainee_id: trainee }
        end
      end
    end
  end
end
