# frozen_string_literal: true

require "rails_helper"

describe TraineeStatusCard::View do
  before do
    render_inline(
      described_class.new(status: "deferred", target: "some_path", count: 24),
    )
  end

  describe "rendered component" do
    it "renders the correct css colour" do
      expect(rendered_content).to have_css(".app-status-card--yellow")
    end

    it "renders the correct text" do
      expect(rendered_content).to have_text("Currently deferred")
    end

    it "renders the trainee count" do
      expect(rendered_content).to have_text("24")
    end

    it "renders the correct filter link" do
      expect(rendered_content).to have_link(href: "some_path")
    end

    context "when count is 1000 or above" do
      before do
        render_inline(
          described_class.new(status: "deferred", target: "some_path", count: 2345),
        )
      end

      it "renders the trainee count as a delimited string" do
        expect(rendered_content).to have_text("2,345")
      end
    end
  end
end
