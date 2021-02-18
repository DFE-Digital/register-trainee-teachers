# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeStatusCard::View do
  include Rails.application.routes.url_helpers
  alias_method :component, :page

  let(:common_provider) { create(:provider) }
  let(:trainee) { create(:trainee, provider: common_provider) }
  let(:user) { create(:user, provider: common_provider) }
  let(:target) { trainees_path("state[]": "draft") }

  describe "#state_name" do
    it "returns a humanized state name" do
      %i[draft withdrawn deferred].each do |state|
        expect(described_class.new(state: state,
                                   target: target, user: user).state_name).to eql(state.to_s.humanize)
      end

      expect(described_class.new(state: :qts_awarded,
                                 target: target, user: user).state_name).to eql("QTS awarded")

      expect(described_class.new(state: :trn_received,
                                 target: target, user: user).state_name).to eql("TRN received")

      expect(described_class.new(state: :submitted_for_trn,
                                 target: target, user: user).state_name).to eql("Pending TRN")

      expect(described_class.new(state: :recommended_for_qts,
                                 target: target, user: user).state_name).to eql("QTS recommended")
    end
  end

  describe "#status_colour" do
    it "returns the correct colour for given state" do
      described_class::STATUS_COLOURS.each_key do |state|
        expect(described_class.new(state: state,
                                   target: target, user: user).status_colour).to eql(described_class::STATUS_COLOURS[state])
      end
    end
  end

  describe "rendered component" do
    before do
      trainee
      render_inline(described_class.new(state: "draft",
                                        target: target, user: user))
    end

    it "renders the correct css colour" do
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
