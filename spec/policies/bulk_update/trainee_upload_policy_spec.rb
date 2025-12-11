# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploadPolicy, type: :policy do
  subject { described_class }

  let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

  it { is_expected.to be < BulkUpdate::TraineeUploads::BasePolicy }

  context "when the User's organisation is an HEI Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :hei), session: {}) }

    %i[uploaded pending validated in_progress succeeded failed].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :index?, :show?, :new?, :create?, :destroy? do
          it { is_expected.to permit(user, trainee_upload) }
        end
      end
    end

    %i[cancelled].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :show?, :create?, :destroy? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
      end
    end
  end

  context "when the User's organisation is not an HEI Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    %i[uploaded pending validated in_progress succeeded failed cancelled].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :index?, :show?, :new?, :create?, :destroy? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
      end
    end
  end

  context "when the User's organisation is not a Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :with_training_partner_organisation), session: {}) }
    let(:trainee_upload) { build(:bulk_update_trainee_upload, provider: user.providers.first) }

    %i[uploaded pending validated in_progress succeeded failed cancelled].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :show?, :new?, :create?, :destroy? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
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
