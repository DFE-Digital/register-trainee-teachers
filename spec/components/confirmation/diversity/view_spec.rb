# frozen_string_literal: true

require "rails_helper"

RSpec.describe Confirmation::Diversity::View do
  before { render_inline(Confirmation::Diversity::View.new(data_model: trainee)) }

  describe "Diversity information" do
    context "when trainee has not shared any ethnic or disability information" do
      let(:trainee) { build(:trainee, :diversity_not_disclosed) }

      it "renders with one line to say the trainee haven't shared data" do
        expect(rendered_component).to have_text("Not shared")
        expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 1)
      end

      it "has one change links" do
        expect(rendered_component).to have_link("Change diversity information")
        expect(rendered_component).not_to have_link("Change ethnicity")
        expect(rendered_component).not_to have_link("Change disability")
      end
    end

    context "when trainee has shared their diversity information " do
      let(:trainee) { build(:trainee, :diversity_disclosed) }

      it "renders with one line to say the trainee has shared data" do
        expect(rendered_component).to have_text("Information disclosed")
        expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 3)
      end

      it "has three change links" do
        expect(rendered_component).to have_link("Change diversity information")
        expect(rendered_component).to have_link("Change ethnicity")
        expect(rendered_component).to have_link("Change disability")
      end
    end
  end

  describe "ethnic selection" do
    let(:trainee) { build(:trainee, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:asian]) }
    let(:expected_locale_key) { t("components.confirmation.diversity.ethnic_groups.asian_ethnic_group") }

    subject { Confirmation::Diversity::View.new(data_model: trainee) }

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

  describe "#disability_selection" do
    let(:disability_disclosure) { nil }
    let(:trainee) { build(:trainee, disability_disclosure: disability_disclosure) }

    let(:rendered_component) { Confirmation::Diversity::View.new(data_model: trainee) }

    it "returns answer missing" do
      expect(rendered_component.disability_selection).to eq("Answer missing")
    end

    context "disabled" do
      let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] }

      it "returns a message stating the user is disabled" do
        expect(rendered_component.disability_selection).to eq("They shared that they’re disabled")
      end
    end

    context "not disabled" do
      let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] }

      it "returns a message stating the user is not disabled" do
        expect(rendered_component.disability_selection).to eq("They shared that they’re not disabled")
      end
    end

    context "not provided" do
      let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }

      it "returns a message stating the user did not provide details" do
        expect(rendered_component.disability_selection).to eq("Not provided")
      end
    end
  end

  describe "selected disability options" do
    let(:trainee) { build(:trainee) }
    let(:rendered_component) { Confirmation::Diversity::View.new(data_model: trainee) }

    context "when there are no disabilities" do
      it "returns a empty string if no disabilities" do
        expect(rendered_component.selected_disability_options).to be_empty
      end
    end

    context "when there are disabilities" do
      let(:disabilities_stub) { [double(name: "some disability")] }

      before do
        allow(trainee).to receive(:disabilities).and_return(disabilities_stub)
      end

      it "renders the disability names" do
        trainee.disabilities.each do |disability|
          expect(rendered_component.selected_disability_options).to include(disability.name)
        end
      end
    end

    context "when additional disability has been provided" do
      let(:disability) { build(:disability, name: Diversities::OTHER) }
      let(:trainee_disability) { build(:trainee_disability, additional_disability: "some additional disability", disability: disability) }
      let(:trainee) { create(:trainee, trainee_disabilities: [trainee_disability]) }

      it "renders the additional disability" do
        expected_text = "#{disability.name.downcase} (#{trainee_disability.additional_disability})"
        expect(rendered_component.selected_disability_options).to include(expected_text)
      end
    end
  end
end
