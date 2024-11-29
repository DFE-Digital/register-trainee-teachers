# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploads::BasePolicy, type: :policy do
  subject { described_class }

  let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

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
