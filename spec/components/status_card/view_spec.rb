# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatusCard::View do
  alias_method :component, :page

  describe "rendered component" do
    before do
      render_inline(described_class.new(status_colour: "grey", count: "1", state_name: "Draft",
                                        target: "/trainees?state%5B%5D=draft"))
    end

    it "renders the correct govuk colour css" do
      expect(component).to have_css(".app-status-card--grey")
    end

    it "renders the correct text" do
      expect(component).to have_text("Draft")
    end

    it "renders the trainee count for those in draft" do
      expect(component).to have_text("1")
    end

    it "renders the correct filter link" do
      expect(component).to have_link(href: "/trainees?state%5B%5D=draft")
    end
  end
end
