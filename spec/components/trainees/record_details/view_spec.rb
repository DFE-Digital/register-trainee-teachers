# frozen_string_literal: true

require "rails_helper"

module Trainees
  module RecordDetails
    describe View do
      include SummaryHelper

      alias_method :component, :page

      let(:trainee) { build(:trainee, created_at: Time.zone.today, updated_at: Time.zone.today) }

      context "when trainee_id data has not been provided" do
        before do
          trainee.trainee_id = nil
          render_inline(View.new(trainee))
        end

        it "tells the user that no data has been entered for trainee ID" do
          expect(component.find(".govuk-summary-list__row.trainee-id .govuk-summary-list__value")).to have_text(t("components.confirmation.not_provided"))
        end
      end

      context "when data has been provided" do
        before do
          render_inline(View.new(trainee))
        end

        it "renders the trainee ID" do
          expect(component.find(summary_card_row_for("trainee-id"))).to have_text(trainee.trainee_id)
        end

        it "renders the trn submission date" do
          expect(component.find(summary_card_row_for("submitted-for-trn"))).to have_text(date_for_summary_view(Time.zone.yesterday))
        end

        it "renders the trainee record last updated date" do
          expect(component.find(summary_card_row_for("last-updated"))).to have_text(date_for_summary_view(trainee.updated_at))
        end

        it "renders the trainee record created date" do
          expect(component.find(summary_card_row_for("record-created"))).to have_text(date_for_summary_view(trainee.created_at))
        end
      end
    end
  end
end
