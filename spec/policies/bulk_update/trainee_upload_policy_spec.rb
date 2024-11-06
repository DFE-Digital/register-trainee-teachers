# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploadPolicy, type: :policy do
  subject { described_class }

  let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

  context "when the User's organisation is a Provider" do
    let(:trainee_upload) { build(:bulk_update_trainee_upload, provider: user.providers.first) }

    permissions :show?, :new?, :create? do
      it { is_expected.to permit(user, trainee_upload) }
    end
  end

  context "when the User's organisation is not a Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :with_lead_partner_organisation), session: {}) }
    let(:trainee_upload) { build(:bulk_update_trainee_upload, provider: user.providers.first) }

    permissions :show?, :new?, :create? do
      it { is_expected.not_to permit(user, trainee_upload) }
    end
  end

  describe described_class::Scope do
    subject do
      described_class.new(user, BulkUpdate::TraineeUpload).resolve
    end

    let(:other_user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    let!(:pending_upload) { create(:bulk_update_trainee_upload, provider: user.providers.first) }
    let!(:other_user_upload) { create(:bulk_update_trainee_upload, provider: other_user.providers.first) }

    it { is_expected.to contain_exactly(pending_upload) }
  end
end
