# frozen_string_literal: true

require "rails_helper"

module Trainees
  module UndoWithdrawals
    describe ConfirmationsController do
      let(:provider) { create(:provider) }
      let(:current_user) { build_current_user(user: create(:user, :system_admin, providers: [provider])) }

      let(:trainee) { create(:trainee, :withdrawn, provider: current_user.organisation) }
      let(:session_data) { {} }

      before do
        allow(controller).to receive_messages(current_user: current_user, session: session_data)
      end

      describe "GET #show" do
        it "renders the show template" do
          get :show, params: { trainee_id: trainee.slug }
          expect(response).to render_template(:show)
        end
      end

      describe "PATCH #update" do
        let(:undo_withdrawal_form) { instance_double(UndoWithdrawalForm) }

        before do
          allow(UndoWithdrawalForm).to receive(:new).and_return(undo_withdrawal_form)
        end

        context "when the form saves successfully" do
          before do
            allow(undo_withdrawal_form).to receive(:save).and_return(true)
          end

          it "enqueues TRS update job" do
            expect(Trs::UpdateProfessionalStatusJob).to receive(:perform_later).with(trainee)
            patch :update, params: { trainee_id: trainee.slug }
          end

          it "redirects to the trainee page with success message" do
            allow(Trs::UpdateProfessionalStatusJob).to receive(:perform_later)
            patch :update, params: { trainee_id: trainee.slug }

            expect(response).to redirect_to(trainee_path(trainee))
            expect(flash[:success]).to eq("Withdrawal undone")
          end
        end

        context "when the form save fails" do
          before do
            allow(undo_withdrawal_form).to receive(:save).and_return(false)
          end

          it "redirects to the trainee page with a warning message" do
            patch :update, params: { trainee_id: trainee.slug }

            expect(response).to redirect_to(trainee_path(trainee))
            expect(flash[:warning]).to eq("Unable to undo the trainee Withdrawal. Please contact support.")
          end

          it "does not enqueue TRS update job" do
            expect(Trs::UpdateProfessionalStatusJob).not_to receive(:perform_later)
            patch :update, params: { trainee_id: trainee.slug }
          end
        end

        context "when an exception is raised" do
          let(:error) { StandardError.new("Something went wrong") }

          before do
            allow(undo_withdrawal_form).to receive(:save).and_raise(error)
          end

          it "captures the exception with Sentry" do
            expect(Sentry).to receive(:capture_exception).with(error)
            patch :update, params: { trainee_id: trainee.slug }
          end

          it "redirects to the trainee page with a warning message" do
            allow(Sentry).to receive(:capture_exception)
            patch :update, params: { trainee_id: trainee.slug }

            expect(response).to redirect_to(trainee_path(trainee))
            expect(flash[:warning]).to eq("Unable to undo the trainee Withdrawal. Please contact support.")
          end
        end
      end

      describe "DELETE #destroy" do
        let(:undo_withdrawal_form) { instance_double(UndoWithdrawalForm) }

        before do
          allow(UndoWithdrawalForm).to receive(:new).and_return(undo_withdrawal_form)
          allow(undo_withdrawal_form).to receive(:delete!)
        end

        it "calls delete! on the form" do
          expect(undo_withdrawal_form).to receive(:delete!)
          delete :destroy, params: { trainee_id: trainee.slug }
        end

        it "redirects to the trainee page" do
          delete :destroy, params: { trainee_id: trainee.slug }
          expect(response).to redirect_to(trainee_path(trainee))
        end
      end

      describe "helper methods" do
        let(:undo_withdrawal_form) { instance_double(UndoWithdrawalForm, comment: "Test comment", ticket: "TICKET-123", previous_state: "trn_received") }

        before do
          allow(UndoWithdrawalForm).to receive(:new).and_return(undo_withdrawal_form)
          get :show, params: { trainee_id: trainee.slug }
        end

        describe "#comment" do
          it "returns the comment from undo_withdrawal_form" do
            expect(controller.send(:comment)).to eq("Test comment")
          end
        end

        describe "#ticket" do
          it "returns the ticket from undo_withdrawal_form" do
            expect(controller.send(:ticket)).to eq("TICKET-123")
          end
        end

        describe "#state" do
          it "returns the previous state from undo_withdrawal_form" do
            expect(controller.send(:state)).to eq("trn_received")
          end
        end

        describe "#undo_withdrawal_form" do
          it "creates the form with trainee and session" do
            controller.send(:undo_withdrawal_form)
            expect(UndoWithdrawalForm).to have_received(:new).with(trainee: trainee, session: session_data)
          end

          it "memoizes the form" do
            controller.send(:undo_withdrawal_form)
            controller.send(:undo_withdrawal_form)
            expect(UndoWithdrawalForm).to have_received(:new).once
          end
        end
      end
    end
  end
end
