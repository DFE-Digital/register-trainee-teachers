# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Confirmation::Diversity::View do
  alias_method :component, :page

  let(:trainee) do
    mock_trainee
  end

  describe "Diversity information" do
    context "when trainee has not shared any ethnic or disability information" do
      before do
        trainee.diversity_disclosure = "diversity_not_disclosed"
        render_inline(Trainees::Confirmation::Diversity::View.new(trainee: trainee))
      end

      it "renders with one line to say the train haven't shared data" do
        expect(component.find(".diversity-information .govuk-summary-list__value")).to have_text("Not shared")
        expect(component).to have_selector(".govuk-summary-list__row", count: 1)
      end

      it "has one change links" do
        expect(component).to have_link("Change diversity information")
        expect(component).not_to have_link("Change ethnicity")
        expect(component).not_to have_link("Change disability")
      end
    end

    context "when trainee has shared their diversity information " do
      before do
        trainee.diversity_disclosure = "diversity_disclosed"
        render_inline(Trainees::Confirmation::Diversity::View.new(trainee: trainee))
      end

      it "renders with one line to say the train haven't shared data" do
        expect(component.find(".diversity-information .govuk-summary-list__value")).to have_text("Information disclosed")
        expect(component).to have_selector(".govuk-summary-list__row", count: 3)
      end

      it "has three change links" do
        expect(component).to have_link("Change diversity information")
        expect(component).to have_link("Change ethnicity")
        expect(component).to have_link("Change disability")
      end
    end
  end

  describe "#ethnic_group_content" do
    before do
      allow(I18n).to receive(:t).with("components.confirmation.diversity.ethnic_groups.#{trainee.ethnic_group}").and_return("New ethnic group")
    end

    it "returns just the ethnic if not ethnic group is present or no provided" do
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.ethnic_group_content).to eq "New ethnic group"
    end

    it "returns the ethnic background" do
      trainee.ethnic_background = "Ethnic background"
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.ethnic_group_content).to eq "New ethnic group (Ethnic background)"
    end
  end

  describe "#get_disability_selection" do
    it "returns a message stating the user is disabled" do
      allow(trainee).to receive(:disabled?).and_return(true)
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.disability_selection).to eq "They shared that they’re disabled"
    end

    it "returns a message stating the user is not disabled" do
      allow(trainee).to receive(:disabled?).and_return(false)
      allow(trainee).to receive(:not_disabled?).and_return(true)
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.disability_selection).to eq "They shared that they’re not disabled"
    end

    it "returns a message stating the user did not provide details" do
      allow(trainee).to receive(:disabled?).and_return(false)
      allow(trainee).to receive(:not_disabled?).and_return(false)
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.disability_selection).to eq "Not provided"
    end
  end

  describe "#selected_disability_options" do
    it "returns a empty string if no disabilities" do
      trainee.disabilities = []
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.selected_disability_options).to be_empty
    end
  end

private

  def mock_trainee
    @mock_trainee ||= create(:trainee)
  end
end
