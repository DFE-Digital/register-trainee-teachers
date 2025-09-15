# frozen_string_literal: true

require "rails_helper"

describe UsersHelper do
  include UsersHelper

  describe "#lead_partner_user?" do
    describe "training partner user" do
      let(:current_user) { double(UserWithOrganisationContext, lead_partner?: true) }

      it "returns true" do
        expect(lead_partner_user?).to be(true)
      end
    end
  end

  describe "#can_view_drafts?" do
    context "with no current_user" do
      it "returns false" do
        expect(can_view_drafts?).to be(false)
      end
    end

    context "with a current_user who is not authorized" do
      let(:current_user) { double(UserWithOrganisationContext) }
      let(:user_policy) { double(UserPolicy, drafts?: false) }

      it "returns false" do
        allow(UserPolicy).to receive(:new).and_return(user_policy)
        expect(can_view_drafts?).to be(false)
      end
    end

    context "with a current_user who is authorized" do
      let(:current_user) { double(UserWithOrganisationContext) }
      let(:user_policy) { double(UserPolicy, drafts?: true) }

      it "returns true" do
        allow(UserPolicy).to receive(:new).and_return(user_policy)
        expect(can_view_drafts?).to be(true)
      end
    end
  end

  describe "#can_bulk_recommend?" do
    context "with no current_user" do
      it "returns false" do
        expect(can_bulk_recommend?).to be(false)
      end
    end

    context "with a current_user who is not authorized" do
      let(:current_user) { double(UserWithOrganisationContext) }
      let(:user_policy) { double(UserPolicy, bulk_recommend?: false) }

      it "returns false" do
        allow(UserPolicy).to receive(:new).and_return(user_policy)
        expect(can_bulk_recommend?).to be(false)
      end
    end

    context "with a current_user who is authorized" do
      let(:current_user) { double(UserWithOrganisationContext) }
      let(:user_policy) { double(UserPolicy, bulk_recommend?: true) }

      it "returns true" do
        allow(UserPolicy).to receive(:new).and_return(user_policy)
        expect(can_bulk_recommend?).to be(true)
      end
    end
  end
end
