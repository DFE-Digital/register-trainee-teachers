# frozen_string_literal: true

require "rails_helper"

module DeferralDetails
  describe View do
    include SummaryHelper

    alias_method :component, :page

    let(:trainee_stub) { Trainee.new(defer_date: Time.zone.yesterday) }
    let(:data_model) { OpenStruct.new(trainee: trainee_stub, date: trainee_stub.defer_date) }

    before do
      render_inline(View.new(data_model))
    end

    it "renders the deferral end date" do
      expect(component).to have_text(date_for_summary_view(data_model.date))
    end
  end
end
