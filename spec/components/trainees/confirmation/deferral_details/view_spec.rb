# frozen_string_literal: true

require "rails_helper"

module Trainees
  module DeferralDetails
    describe View do
      include SummaryHelper

      alias_method :component, :page

      let(:trainee) { Trainee.new(id: 1, defer_date: Time.zone.yesterday) }

      before do
        render_inline(View.new(trainee))
      end

      it "renders the deferral end date" do
        expect(component).to have_text(date_for_summary_view(trainee.defer_date))
      end
    end
  end
end
