# frozen_string_literal: true

require "rails_helper"

describe YearChangeBanner::View do
  let(:current_date) { Date.new(2023, 6, 1) }

  before do
    Timecop.freeze(current_date) do
      create(:academic_cycle)
      @result = render_inline(YearChangeBanner::View.new)
    end
  end

  context "in June" do
    it "renders nothing" do
      expect(@result.text).to be_blank
    end
  end

  context "in July" do
    let(:current_date) { Date.new(2023, 7, 1) }

    it "renders the 'new academic year imminent' banner" do
      expect(@result.text).to include("The 2023 to 2024 academic year will start on 1 August")
    end
  end

  context "in August" do
    let(:current_date) { Date.new(2023, 8, 15) }

    it "renders the 'new academic year has just started' banner" do
      expect(@result.text).to include("The 2023 to 2024 academic year started on 1 August")
    end
  end
end
