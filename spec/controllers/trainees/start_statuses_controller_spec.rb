# frozen_string_literal: true

require "rails_helper"

describe Trainees::StartStatusesController do
  include ActiveJob::TestHelper

  describe "#update" do
    let(:current_user) { build_current_user }
    let(:page_context) { nil }

    let(:send_request) do
      post(:update,
           params: {
             trainee_id: trainee,
             trainee_start_status_form: {
               "commencement_status" => "itt_started_on_time",
               "trainee_start_date(3i)" => "",
               "trainee_start_date(2i)" => "",
               "trainee_start_date(1i)" => "",
               context: page_context,
             },
           })
    end

    before do
      allow(controller).to receive_messages(current_user: current_user, authorize_trainee: true)
    end

    context "when the trainee is draft" do
      context "but not submission ready" do
        let(:trainee) { create(:trainee, :with_study_mode_and_course_dates) }

        it "does not submit for TRN" do
          expect(Trainees::SubmitForTrn).not_to receive(:call)
          send_request
        end
      end

      context "and submission ready" do
        let(:trainee) { create(:trainee, :completed) }

        it "submits for TRN" do
          expect(Trainees::SubmitForTrn).to receive(:call).with({ trainee: })
          send_request
        end
      end
    end

    context "when the trainee is not draft" do
      let(:trainee) { create(:trainee, :submitted_for_trn) }

      it "does not submit them for TRN" do
        expect(Trainees::SubmitForTrn).not_to receive(:call)
        send_request
      end
    end

    context "updating trainee start status in a different context" do
      let(:trainee) { create(:trainee, :submitted_for_trn) }

      before { send_request }

      context "delete" do
        let(:page_context) { :delete }

        it "redirects to the delete forbidden page" do
          expect(response).to redirect_to(trainee_forbidden_deletes_path(trainee))
        end
      end

      context "withdrawal form has not started and contains no date" do
        let(:page_context) { :withdraw }

        it "redirects to the withdrawal page" do
          expect(response).to redirect_to(edit_trainee_withdrawal_date_path(trainee))
        end
      end

      context "withdrawal form has started and the trainee start date is before the withdrawal date" do
        let!(:trainee) { create(:trainee, :submitted_for_trn, :withdrawn) }
        let(:page_context) { :withdraw }

        it "redirects to the withdrawal confirmation page" do
          expect(response).to redirect_to(edit_trainee_withdrawal_confirm_detail_path(trainee))
        end
      end
    end
  end
end
