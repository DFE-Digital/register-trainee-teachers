# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Confirmation::Diversity::View do
  alias_method :component, :page

  let(:trainee) { create(:trainee) }

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
    let(:trainee) { build(:trainee, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:asian]) }
    let(:expected_locale_key) { t("components.confirmation.diversity.ethnic_groups.asian_ethnic_group") }

    subject { Trainees::Confirmation::Diversity::View.new(trainee: trainee) }

    it "returns the ethnic_group if the ethnic_background is not provided" do
      expect(subject.ethnic_group_content).to eq(expected_locale_key)
    end

    context "ethnic background" do
      let(:ethnic_background) { Diversities::ANOTHER_ETHNIC_BACKGROUND }
      let(:trainee) { build(:trainee, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:other], ethnic_background: ethnic_background) }
      let(:expected_locale_key) { t("components.confirmation.diversity.ethnic_groups.other_ethnic_group") }

      context "when ethnic_background provided" do
        it "returns the ethnic_background alongside the ethnic_group" do
          expect(subject.ethnic_group_content).to eq("#{expected_locale_key} (#{ethnic_background})")
        end
      end

      context "when additional_ethnic_background provided" do
        let(:additional_background) { "some additional background" }

        before do
          trainee.additional_ethnic_background = additional_background
        end

        it "returns the additional_ethnic_background alongside the ethnic_group" do
          expect(subject.ethnic_group_content).to eq("#{expected_locale_key} (#{additional_background})")
        end
      end
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
      allow(trainee).to receive(:no_disability?).and_return(true)
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.disability_selection).to eq "They shared that they’re not disabled"
    end

    it "returns a message stating the user did not provide details" do
      allow(trainee).to receive(:disabled?).and_return(false)
      allow(trainee).to receive(:no_disability?).and_return(false)
      component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      expect(component.disability_selection).to eq "Not provided"
    end
  end

  describe "#selected_disability_options" do
    let(:component) { Trainees::Confirmation::Diversity::View.new(trainee: trainee) }

    context "when there are no disabilities" do
      it "returns a empty string if no disabilities" do
        expect(component.selected_disability_options).to be_empty
      end
    end

    context "when there are disabilities" do
      let(:disabilities_stub) { [double(name: "some disability")] }

      before do
        allow(trainee).to receive(:disabilities).and_return(disabilities_stub)
      end

      it "renders the disability names" do
        trainee.disabilities.each do |disability|
          expect(component.selected_disability_options).to include(disability.name)
        end
      end
    end

    context "when additional disability has been provided" do
      let(:disability) { build(:disability, name: Diversities::OTHER) }
      let(:trainee_disability) { build(:trainee_disability, additional_disability: "some additional disability", disability: disability) }
      let(:trainee) { create(:trainee, trainee_disabilities: [trainee_disability]) }

      it "renders the additional disability" do
        expected_text = "#{disability.name.downcase} (#{trainee_disability.additional_disability})"
        expect(component.selected_disability_options).to include(expected_text)
      end
    end
  end
end
