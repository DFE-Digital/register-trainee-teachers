# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeStatusCard::View do
  before do
    render_inline(
      described_class.new(status: "deferred", target: "some_path", count: 1),
    )
  end

  describe "rendered component" do
    it "renders the correct css colour" do
      expect(rendered_component).to have_css(".app-status-card--yellow")
    end

    it "renders the correct text" do
      expect(rendered_component).to have_text("Currently deferred")
    end

    it "renders the trainee count" do
      expect(rendered_component).to have_text("1")
    end

    it "renders the correct filter link" do
      expect(rendered_component).to have_link(href: "some_path")
    end
  end
end
