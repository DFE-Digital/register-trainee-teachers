# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionsController do
  include ActiveJob::TestHelper

  describe "#create" do
    let(:current_user) { build_current_user }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    context "when all sections are completed" do
      context "and the itt start date is in the future" do
        let(:trainee) do
          create(
            :trainee,
            :completed,
            :with_study_mode_and_future_course_dates,
            provider: current_user.organisation,
          )
        end

        context "and the provider is accredited" do
          before do
            allow(current_user.organisation).to receive(:accredited?).and_return(true)
          end

          it "calls the SubmitForTrn service" do
            expect(Trainees::SubmitForTrn).to receive(:call).with({ trainee: })
            post :create, params: { trainee_id: trainee }
          end
        end

        context "and the provider is unaccredited" do
          before do
            allow(current_user.organisation).to receive(:accredited?).and_return(false)
          end

          it "calls the SubmitForTrn service" do
            expect(Trainees::SubmitForTrn).to receive(:call).with({ trainee: })
            post :create, params: { trainee_id: trainee }
          end
        end
      end

      context "and the itt start date is in the past" do
        let(:trainee) { create(:trainee, :completed, provider: current_user.organisation) }

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
