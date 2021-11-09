# frozen_string_literal: true

require "rails_helper"

describe Trainees::StartStatusesController, type: :controller do
  include ActiveJob::TestHelper

  describe "#update" do
    let(:current_user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    context "when the trainee is draft" do
      context "but not submission ready" do
        let(:trainee) { create(:trainee) }

        it "does not submit for TRN" do
          expect(Trainees::SubmitForTrn).not_to receive(:call)
          post(:update, params: { trainee_id: trainee })
        end
      end

      context "and submission ready" do
        let(:trainee) { create(:trainee, :completed) }

        it "submits for TRN" do
          expect(Trainees::SubmitForTrn).not_to receive(:call).with({ trainee: trainee, dttp_id: current_user.dttp_id })
          post(:update, params: { trainee_id: trainee })
        end
      end
    end

    context "when the trainee is not draft" do
      let(:trainee) { create(:trainee, :submitted_for_trn) }

      it "does not submit them for TRN" do
        expect(Trainees::SubmitForTrn).not_to receive(:call)
        post(:update, params: { trainee_id: trainee })
      end
    end
  end
end
