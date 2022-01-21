# frozen_string_literal: true

require "rails_helper"

describe UserWithOrganisationContext do
  let(:user) { create(:user, id: 1, first_name: "Dave", providers: [provider]) }
  let(:session) { {} }
  let(:provider) { create(:provider) }
  let(:lead_school) { create(:school, :lead) }

  subject do
    described_class.new(user: user, session: session)
  end

  before do
    disable_features("google.send_data_to_big_query")
  end

  it "delegates missing methods to user" do
    expect(subject.id).to eq(1)
    expect(subject.first_name).to eq("Dave")
  end

  describe "#organisation" do
    subject { super().organisation }

    context "feature is not enabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      it { is_expected.to eq(user.providers.first) }
    end

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider], lead_schools: [lead_school]) }

        context "provider is set in the session" do
          let(:session) { { current_organisation: { id: provider.id, type: "Provider" } } }

          it { is_expected.to eq(provider) }
        end

        context "lead school is set in the session" do
          let(:session) { { current_organisation: { id: lead_school.id, type: "School" } } }

          it { is_expected.to eq(lead_school) }
        end

        context "no organisation is set in the session" do
          it { is_expected.to be_nil }
        end
      end

      context "user has one provider" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to eq(provider) }
      end
    end
  end

  describe "#provider?" do
    subject { super().provider? }

    context "feature is not enabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      it { is_expected.to eq(true) }
    end

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider], lead_schools: [lead_school]) }

        context "provider is set in the session" do
          let(:session) { { current_organisation: { id: provider.id, type: "Provider" } } }

          it { is_expected.to eq(true) }
        end

        context "lead school is set in the session" do
          let(:session) { { current_organisation: { id: lead_school.id, type: "School" } } }

          it { is_expected.to eq(false) }
        end

        context "no organisation is set in the session" do
          it { is_expected.to eq(false) }
        end
      end

      context "user has one provider" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to eq(true) }
      end
    end
  end

  describe "#lead_school?" do
    subject { super().lead_school? }

    context "feature is not enabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      it { is_expected.to eq(false) }
    end

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, lead_schools: [lead_school], providers: [provider]) }

        context "provider is set in the session" do
          let(:session) { { current_organisation: { id: lead_school.id, type: "Provider" } } }

          it { is_expected.to eq(false) }
        end

        context "lead school is set in the session" do
          let(:session) { { current_organisation: { id: lead_school.id, type: "School" } } }

          it { is_expected.to eq(true) }
        end

        context "no organisation is set in the session" do
          it { is_expected.to eq(false) }
        end
      end
    end
  end

  describe "multiple_organisations?" do
    subject { super().multiple_organisations? }

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, lead_schools: [lead_school], providers: [provider]) }

        it { is_expected.to eq(true) }
      end

      context "user doesn't have multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to eq(false) }
      end
    end

    context "multi organisation feature is disabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, lead_schools: [lead_school], providers: [provider]) }

        it { is_expected.to eq(false) }
      end

      context "user doesn't have multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to eq(false) }
      end
    end
  end

  describe "#user" do
    subject { super().user }

    it { is_expected.to eq(user) }
  end

  describe "#is_a?" do
    it "pretends to be a user" do
      expect(subject.is_a?(User)).to eq(true)
    end
  end

  describe "#class_name" do
    it "pretends to be a user" do
      expect(subject.class_name).to eq("User")
    end
  end

  describe ".primary_key" do
    it "returns 'id'" do
      expect(described_class.primary_key).to eq("id")
    end
  end
end
