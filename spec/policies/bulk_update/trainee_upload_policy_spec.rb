# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploadPolicy, type: :policy do
  subject { described_class }

  let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

  %i[validated].each do |status|
    context "when the upload is #{status}" do
      let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

      permissions :create? do
        it { is_expected.to permit(user, trainee_upload) }
      end

      permissions :show? do
        it { is_expected.not_to permit(user, trainee_upload) }
      end
    end
  end

  %i[submitted succeeded].each do |status|
    context "when the upload is #{status}" do
      let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

      permissions :create? do
        it { is_expected.not_to permit(user, trainee_upload) }
      end

      permissions :show? do
        it { is_expected.to permit(user, trainee_upload) }
      end
    end
  end

  %i[pending failed].each do |status|
    context "when the upload is #{status}" do
      let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

      permissions :create?, :show? do
        it {
          expect(subject).not_to permit(user, trainee_upload)
        }
      end
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
