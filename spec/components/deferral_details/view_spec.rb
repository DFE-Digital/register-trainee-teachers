# frozen_string_literal: true

require "rails_helper"

module DeferralDetails
  describe View do
    include SummaryHelper
    include ActionView::Helpers::SanitizeHelper

    alias_method :component, :page

    let(:data_model) { OpenStruct.new(trainee: trainee_stub, date: trainee_stub.defer_date, itt_start_date: Time.zone.today) }

    before do
      render_inline(View.new(data_model))
    end

    context "itt start date is in the past" do
      let(:trainee_stub) { Trainee.new(defer_date: Time.zone.yesterday) }

      it "renders the deferral date" do
        expect(component).to have_text(date_for_summary_view(data_model.date))
      end

      it "renders the itt start date" do
        expect(component).to have_text(date_for_summary_view(data_model.itt_start_date))
      end

      context "when trainee did not start" do
        let(:trainee_stub) { Trainee.new }

        it "renders the deferred before starting" do
          expect(component).to have_text(strip_tags(t("deferral_details.view.itt_started_but_trainee_did_not_start")))
        end
      end
    end

    context "itt start date is in the future" do
      let(:trainee_stub) { Trainee.new(itt_start_date: 1.year.from_now) }

      it "renders the deferred before itt start date message" do
        expect(component).to have_text(strip_tags(t("deferral_details.view.deferred_before_itt_started")))
      end
    end
  end
end
