# frozen_string_literal: true

require "rails_helper"

describe UserWithOrganisationContext do
  let(:user) { create(:user, id: 1, first_name: "Dave", providers: [provider]) }
  let(:session) { {} }
  let(:provider) { create(:provider) }
  let(:school_training_partner) { create(:training_partner, :school) }
  let(:hei_training_partner) { create(:training_partner, :hei) }

  subject do
    described_class.new(user:, session:)
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

      context "user has a lead partner and a provider" do
        let(:user) { create(:user, id: 1, first_name: "Dave", providers: [provider], training_partners: [school_training_partner]) }

        it { is_expected.to eq(user.providers.first) }
      end

      context "user has only a lead partner" do
        let(:user) { create(:user, id: 1, first_name: "Dave", providers: [], training_partners: [school_training_partner]) }

        it "raises not authorised" do
          expect { subject }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider], training_partners: [school_training_partner]) }

        context "provider is set in the session" do
          let(:session) { { current_organisation: { id: provider.id, type: "Provider" } } }

          it { is_expected.to eq(provider) }
        end

        context "lead partner is set in the session" do
          let(:session) { { current_organisation: { id: school_training_partner.id, type: "LeadPartner" } } }

          it { is_expected.to eq(school_training_partner) }
        end

        context "no organisation is set in the session" do
          it { is_expected.to be_nil }
        end
      end

      context "user has only one provider" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to eq(provider) }
      end

      context "user has only one lead partner" do
        let(:user) { create(:user, id: 1, providers: [], training_partners: [school_training_partner]) }

        it { is_expected.to eq(school_training_partner) }
      end
    end
  end

  describe "#provider?" do
    subject { super().provider? }

    context "feature is not enabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      it { is_expected.to be(true) }
    end

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider], training_partners: [school_training_partner]) }

        context "provider is set in the session" do
          let(:session) { { current_organisation: { id: provider.id, type: "Provider" } } }

          it { is_expected.to be(true) }
        end

        context "no organisation is set in the session" do
          it { is_expected.to be(false) }
        end
      end

      context "user has one provider" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to be(true) }
      end
    end
  end

  describe "#training_partner?" do
    subject { super().training_partner? }

    context "feature is not enabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      it { is_expected.to be(false) }
    end

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, training_partners: [school_training_partner], providers: [provider]) }

        context "provider is set in the session" do
          let(:session) { { current_organisation: { id: school_training_partner.id, type: "Provider" } } }

          it { is_expected.to be(false) }
        end

        context "lead partner is set in the session" do
          let(:session) { { current_organisation: { id: school_training_partner.id, type: "LeadPartner" } } }

          it { is_expected.to be(true) }
        end

        context "no organisation is set in the session" do
          it { is_expected.to be(false) }
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
        let(:user) { create(:user, id: 1, training_partners: [school_training_partner], providers: [provider]) }

        it { is_expected.to be(true) }
      end

      context "user doesn't have multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to be(false) }
      end
    end

    context "multi organisation feature is disabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      context "user has multiple organisations" do
        let(:user) { create(:user, id: 1, training_partners: [school_training_partner], providers: [provider]) }

        it { is_expected.to be(false) }
      end

      context "user doesn't have multiple organisations" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to be(false) }
      end
    end
  end

  describe "no_organisation?" do
    subject { super().no_organisation? }

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      context "user has no organisations" do
        let(:user) { create(:user, id: 1, providers: []) }

        it { is_expected.to be(true) }
      end

      context "user has an organisation" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to be(false) }
      end

      context "user is system admin" do
        let(:user) { create(:user, :system_admin) }

        it { is_expected.to be(false) }
      end
    end

    context "multi organisation feature is disabled" do
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      context "user has no organisations" do
        let(:user) { create(:user, id: 1, training_partners: [], providers: []) }

        it { is_expected.to be(false) }
      end

      context "user has an organisation" do
        let(:user) { create(:user, id: 1, providers: [provider]) }

        it { is_expected.to be(false) }
      end

      context "user is system admin" do
        let(:user) { create(:user, :system_admin) }

        it { is_expected.to be(false) }
      end
    end
  end

  describe "#user" do
    subject { super().user }

    it { is_expected.to eq(user) }
  end

  describe "#is_a?" do
    it "pretends to be a user" do
      expect(subject.is_a?(User)).to be(true)
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

  describe "#hei_provider?" do
    subject { described_class.new(user:, session:).hei_provider? }

    context "when the organisation is a provider" do
      context "and the provider is an HEI" do
        let(:provider) { create(:provider, :hei) }

        it { is_expected.to be true }
      end

      context "and the provider is not a HEI" do
        let(:provider) { create(:provider, :scitt) }

        it { is_expected.to be false }
      end
    end

    context "when the organisation is a lead partner" do
      let(:user) { create(:user, id: 1, first_name: "Dave", training_partners: [hei_training_partner]) }

      it { is_expected.to be false }
    end
  end

  describe "#accredited_hei_provider?" do
    subject { described_class.new(user:, session:).accredited_hei_provider? }

    context "when the organisation is a provider" do
      context "and the provider is an accredited HEI" do
        let(:provider) { create(:provider, :hei) }

        it { is_expected.to be true }

        it "is accredited" do
          expect(provider.accredited).to be true
        end
      end

      context "and the provider is an unaccredited HEI" do
        let(:provider) { create(:provider, :hei, :unaccredited) }

        it { is_expected.to be false }

        it "is accredited" do
          expect(provider.accredited).to be false
        end
      end

      context "and the provider is not a HEI" do
        let(:provider) { create(:provider, :scitt) }

        it { is_expected.to be false }
      end
    end

    context "when the organisation is a lead partner" do
      let(:user) { create(:user, id: 1, first_name: "Dave", training_partners: [hei_training_partner]) }

      it { is_expected.to be false }
    end
  end

  describe "#accredited_hei_provider_or_hei_training_partner?" do
    subject { described_class.new(user:, session:).accredited_hei_provider_or_hei_training_partner? }

    context "when the organisation is a provider" do
      context "and the provider is an accredited HEI" do
        let(:provider) { create(:provider, :hei) }

        it { is_expected.to be true }

        it "is accredited" do
          expect(provider.accredited).to be true
        end
      end

      context "and the provider is an unaccredited HEI" do
        let(:provider) { create(:provider, :hei, :unaccredited) }

        it { is_expected.to be false }

        it "is accredited" do
          expect(provider.accredited).to be false
        end
      end

      context "and the provider is an previously-accredited HEI that is now a Lead Partner" do
        let!(:hei_training_partner) { create(:training_partner, :hei, provider:) }
        let!(:provider) { create(:provider, :hei, :unaccredited) }
        let(:user) { create(:user, id: 1, first_name: "Dave", providers: [provider]) }

        it { is_expected.to be true }

        it "is accredited" do
          expect(provider.accredited).to be false
        end
      end

      context "and the provider is not an HEI" do
        let(:provider) { create(:provider, :scitt) }

        it { is_expected.to be false }
      end
    end

    context "when the organisation is a lead partner" do
      context "and the lead partner is an HEI" do
        let(:user) { create(:user, id: 1, first_name: "Dave", providers: [], training_partners: [hei_training_partner]) }

        it { is_expected.to be false }
      end

      context "and the lead partner is not an HEI" do
        let(:user) { create(:user, id: 1, first_name: "Dave", providers: [], training_partners: [school_training_partner]) }

        it { is_expected.to be false }
      end
    end
  end
end
