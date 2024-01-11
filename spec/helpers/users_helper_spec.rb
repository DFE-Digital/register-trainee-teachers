# frozen_string_literal: true

require "rails_helper"

describe UsersHelper do
  include UsersHelper

  describe "#lead_school_user?" do
    describe "lead school user" do
      let(:current_user) { double(UserWithOrganisationContext, lead_school?: true) }

      it "returns true" do
        expect(lead_school_user?).to be(true)
      end
    end

    describe "non-lead school user" do
      let(:current_user) { double(UserWithOrganisationContext, lead_school?: false) }

      it "returns false" do
        expect(lead_school_user?).to be(false)
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

  describe "#can_view_funding_uploads?" do
    subject { can_view_funding_uploads? }

    context "with nil current_user" do
      let(:current_user) { nil }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "without a current_user as system admin" do
      let(:current_user) { double(UserWithOrganisationContext, system_admin: false) }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "with a current_user as system admin" do
      let(:current_user) { double(UserWithOrganisationContext, system_admin: true) }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "upload funding feature flag is disabled", feature_funding_uploads: false do
      it "returns false" do
        expect(subject).to be_falsey
      end

      context "with a current_user as system admin" do
        let(:current_user) { double(UserWithOrganisationContext, system_admin: true) }

        it "returns false" do
          expect(subject).to be_falsey
        end
      end
    end
  end
end
