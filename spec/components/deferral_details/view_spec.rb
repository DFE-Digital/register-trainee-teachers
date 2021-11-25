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

    context "course start date is in the past" do
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
          expect(component).to have_text(strip_tags(t("deferral_details.view.deferred_before_starting")))
        end
      end
    end

    context "course start date is in the future" do
      let(:trainee_stub) { Trainee.new }

      it "renders the deferred before course start date message" do
        expect(component).to have_text(strip_tags(t("deferral_details.view.deferred_before_starting")))
      end
    end
  end
end
