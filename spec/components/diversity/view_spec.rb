# frozen_string_literal: true

require "rails_helper"

RSpec.describe Diversity::View do
  before { render_inline(Diversity::View.new(data_model: trainee)) }

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
      let(:trainee) { create(:trainee, :with_diversity_information) }

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
    let(:trainee) { build(:trainee, :diversity_disclosed, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:asian]) }
    let(:locale_key) { t("components.confirmation.diversity.ethnic_groups.asian_ethnic_group") }

    it "returns ethnicity is missing" do
      expect(rendered_component).to have_text("Ethnicity is missing")
      expect(rendered_component).not_to have_text(locale_key)
    end

    context "when ethnic_background is not provided" do
      let(:trainee) { build(:trainee, :diversity_disclosed, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:asian], ethnic_background: Diversities::NOT_PROVIDED) }

      it "returns the ethnic_group" do
        expect(rendered_component).to have_text(locale_key)
      end
    end

    context "ethnic background" do
      let(:ethnic_background) { Diversities::ANOTHER_ETHNIC_BACKGROUND }
      let(:trainee) { build(:trainee, :diversity_disclosed, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:other], ethnic_background: ethnic_background) }
      let(:locale_key) { t("components.confirmation.diversity.ethnic_groups.other_ethnic_group") }

      context "when ethnic_background provided" do
        it "returns the ethnic_background alongside the ethnic_group" do
          expect(rendered_component).to have_text("#{locale_key} (#{ethnic_background})")
        end
      end

      context "when additional_ethnic_background provided" do
        let(:additional_background) { "some additional background" }
        let(:trainee) { build(:trainee, :diversity_disclosed, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:other], ethnic_background: ethnic_background, additional_ethnic_background: additional_background) }

        it "returns the additional_ethnic_background alongside the ethnic_group" do
          expect(rendered_component).to have_text("#{locale_key} (#{additional_background})")
        end
      end
    end
  end

  describe "#disability_selection" do
    let(:disability_disclosure) { nil }
    let(:trainee) { build(:trainee, :diversity_disclosed, disability_disclosure: disability_disclosure) }

    it "returns disability is missing" do
      expect(rendered_component).to have_text("Disability is missing")
    end

    context "disabled" do
      let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] }
      let(:trainee) { create(:trainee, :diversity_disclosed, :disabled_with_disabilites_disclosed, disability_disclosure: disability_disclosure) }

      it "returns a message stating the user is disabled" do
        expect(rendered_component).to have_text("They shared that they’re disabled")
      end
    end

    context "not disabled" do
      let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] }

      it "returns a message stating the user is not disabled" do
        expect(rendered_component).to have_text("They shared that they’re not disabled")
      end
    end

    context "not provided" do
      let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }

      it "returns a message stating the user did not provide details" do
        expect(rendered_component).to have_text("Not provided")
      end
    end
  end

  describe "selected disability options" do
    let(:trainee) { create(:trainee, :diversity_disclosed, :disabled) }

    context "when there are no disabilities" do
      it "returns disability is missing" do
        expect(rendered_component).to have_text("Disability is missing")
      end
    end

    context "when there are disabilities" do
      let(:trainee) { create(:trainee, :diversity_disclosed, :disabled_with_disabilites_disclosed) }

      it "renders the disability names" do
        trainee.disabilities.each do |disability|
          expect(rendered_component).to have_text(disability.name)
        end
      end
    end

    context "when additional disability has been provided" do
      let(:disability) { build(:disability, name: Diversities::OTHER) }
      let(:trainee_disability) { build(:trainee_disability, additional_disability: "some additional disability", disability: disability) }
      let(:trainee) { create(:trainee, :diversity_disclosed, :disabled, trainee_disabilities: [trainee_disability]) }

      it "renders the additional disability" do
        expected_text = "#{disability.name.downcase} (#{trainee_disability.additional_disability})"
        expect(rendered_component).to have_text(expected_text)
      end
    end
  end
end
