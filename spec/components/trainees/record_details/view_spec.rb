# frozen_string_literal: true

require "rails_helper"

module Trainees
  module RecordDetails
    describe View do
      include SummaryHelper

      alias_method :component, :page

      let(:state) { :trn_received }
      let(:trainee) { create(:trainee, state, trn: Faker::Number.number(digits: 10)) }
      let(:trainee_status) { "trainee-status" }
      let(:timeline_event) { double(date: Time.zone.today) }

      context "when trainee_id data has not been provided" do
        before do
          trainee.trainee_id = nil
          render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
        end

        it "tells the user that no data has been entered for trainee ID" do
          expect(component.find(".govuk-summary-list__row.trainee-id .govuk-summary-list__value")).to have_text(t("components.confirmation.not_provided"))
        end
      end

      context "when trainee_id data has been provided" do
        before do
          render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
        end

        it "renders the trainee ID" do
          expect(component.find(summary_card_row_for("trainee-id"))).to have_text(trainee.trainee_id)
        end

        it "renders the trainee's last timeline event date" do
          expect(component.find(summary_card_row_for("last-updated"))).to have_text(date_for_summary_view(timeline_event.date))
        end

        it "renders the trainee record created date" do
          expect(component.find(summary_card_row_for("record-created"))).to have_text(date_for_summary_view(trainee.created_at))
        end

        context "when trainee state is submitted_for_trn" do
          let(:trainee) { create(:trainee, :submitted_for_trn) }

          it "renders the trn submission date" do
            expect(component.find(summary_card_row_for("submitted-for-trn"))).to have_text(date_for_summary_view(trainee.submitted_for_trn_at))
          end
        end

        context "when trainee state is deferred" do
          let(:state) { :deferred }

          it "renders the trainee deferral date" do
            expect(component.find(summary_card_row_for(trainee_status))).to have_text(date_for_summary_view(trainee.defer_date))
          end

          it "renders the trainee status tag" do
            expect(component.find(summary_card_row_for(trainee_status))).to have_text("deferred")
          end
        end

        context "when trainee state is withdrawn" do
          let(:state) { :withdrawn }

          it "renders the trainee withdrawal date" do
            expect(component.find(summary_card_row_for(trainee_status))).to have_text(date_for_summary_view(trainee.withdraw_date))
          end
        end
      end
    end
  end
end
