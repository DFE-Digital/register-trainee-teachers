# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeStatusCard::View do
  include Rails.application.routes.url_helpers

  alias_method :component, :page

  let(:current_user) { create(:user, system_admin: true) }
  let(:trainee) { create(:trainee) }
  let(:trainees) { Trainee.all }
  let(:target) { trainees_path("state[]": "draft") }

  describe "#state_name" do
    it "returns state name in correct format" do
      %i[draft withdrawn deferred awarded trn_received submitted_for_trn recommended_for_award].each do |state|
        expect(described_class.new(state: state,
                                   target: target, trainees: trainees).state_name).to eql(I18n.t("activerecord.attributes.trainee.states.#{state}"))
      end
    end
  end

  describe "#status_colour" do
    it "returns the correct colour for given state" do
      described_class::STATUS_COLOURS.each_key do |state|
        expect(described_class.new(state: state,
                                   target: target, trainees: trainees).status_colour).to eql(described_class::STATUS_COLOURS[state])
      end
    end
  end

  describe "rendered component" do
    before do
      trainee
      render_inline(described_class.new(state: "draft",
                                        target: target, trainees: trainees))
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
