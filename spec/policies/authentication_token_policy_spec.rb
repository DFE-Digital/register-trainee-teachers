# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationTokenPolicy, type: :policy do
  subject { described_class }

  context "when the User belongs to an HEI Provider" do
    let(:provider_user) { create(:user, :hei) }
    let(:provider_user_context) { UserWithOrganisationContext.new(user: provider_user, session: {}) }

    permissions :index?, :create?, :new? do
      it { is_expected.to permit(provider_user_context) }
    end
  end

  context "when the User belongs to a SCITT Provider" do
    let(:provider_user) { create(:user, :scitt) }
    let(:provider_user_context) { UserWithOrganisationContext.new(user: provider_user, session: {}) }

    permissions :index?, :create?, :new? do
      it { is_expected.not_to permit(provider_user_context) }
    end
  end

  context "when the User belongs to a LeadPartner" do
    let(:lead_partner_user) { create(:user, :with_lead_partner_organisation) }
    let(:lead_partner_user_context) { UserWithOrganisationContext.new(user: lead_partner_user, session: {}) }

    permissions :index?, :create?, :new? do
      it { is_expected.not_to permit(lead_partner_user_context) }
    end
  end

  context "when the User does not belong to either a Provider or LeadPartner" do
    let(:user_with_no_organisation) { create(:user, :with_no_organisation_in_db) }
    let(:user_with_no_organisation_context) { UserWithOrganisationContext.new(user: user_with_no_organisation, session: {}) }

    permissions :index?, :create?, :new? do
      it { is_expected.not_to permit(user_with_no_organisation_context) }
    end
  end

  describe described_class::Scope do
    context "when the User is an HEI Provider" do
      let!(:provider_user) { create(:user, :hei) }
      let!(:provider_user_context) { UserWithOrganisationContext.new(user: provider_user, session: {}) }

      let!(:provider_user_authentication_tokens) { create_list(:authentication_token, 2, provider: provider_user_context.organisation) }
      let!(:other_provider_user_authentication_tokens) { create_list(:authentication_token, 2) }

      subject { described_class.new(provider_user_context, AuthenticationToken) }

      it "returns only the authentication tokens that belong to the provider of the current user" do
        expect(subject.resolve).to match_array(provider_user_authentication_tokens)
      end
    end

    context "when the User is a SCITT Provider" do
      let!(:provider_user) { create(:user, :scitt) }
      let!(:provider_user_context) { UserWithOrganisationContext.new(user: provider_user, session: {}) }

      let!(:provider_user_authentication_tokens) { create_list(:authentication_token, 2, provider: provider_user_context.organisation) }
      let!(:other_provider_user_authentication_tokens) { create_list(:authentication_token, 2) }

      subject { described_class.new(provider_user_context, AuthenticationToken) }

      it "returns empty" do
        expect(subject.resolve).to be_empty
      end
    end

    context "when the User is a Lead Partner Provider" do
      let!(:lead_partner) { create(:lead_partner, :hei) }
      let!(:lead_partner_user) { create(:user, lead_partners: [lead_partner]) }
      let!(:lead_partner_user_context) {
        UserWithOrganisationContext.new(user: lead_partner_user, session: { current_organisation: { type: "LeadPartner", id: lead_partner.id } })
      }

      let!(:provider_user_authentication_tokens) { create_list(:authentication_token, 2, provider: lead_partner_user_context.organisation.provider) }
      let!(:other_provider_user_authentication_tokens) { create_list(:authentication_token, 2) }

      subject { described_class.new(lead_partner_user_context, AuthenticationToken) }

      it "returns empty" do
        expect(subject.resolve).to be_empty
      end
    end

    context "when the User is a Lead Partner School" do
      let!(:lead_partner) { create(:lead_partner, :school) }
      let!(:lead_partner_user) { create(:user, lead_partners: [lead_partner]) }
      let!(:lead_partner_user_context) {
        UserWithOrganisationContext.new(user: lead_partner_user, session: { current_organisation: { type: "LeadPartner", id: lead_partner.id } })
      }

      let!(:provider_user_authentication_tokens) { create_list(:authentication_token, 2, provider: lead_partner_user.providers.take) }
      let!(:other_provider_user_authentication_tokens) { create_list(:authentication_token, 2) }

      subject { described_class.new(lead_partner_user_context, AuthenticationToken) }

      it "returns empty" do
        expect(subject.resolve).to be_empty
      end
    end

    context "when the User does not have an organisation" do
      let!(:user) { create(:user, :with_no_organisation_in_db) }
      let!(:user_context) { UserWithOrganisationContext.new(user: user, session: {}) }

      subject { described_class.new(user_context, AuthenticationToken) }

      it "returns empty" do
        expect(subject.resolve).to be_empty
      end
    end
  end
end
