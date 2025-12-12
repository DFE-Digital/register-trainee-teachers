# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::Submissions::TraineeUploadPolicy, type: :policy do
  subject { described_class }

  let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

  it { is_expected.to be < BulkUpdate::TraineeUploadPolicy }

  context "when the User's organisation is an HEI Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :hei), session: {}) }

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

    %i[in_progress succeeded failed].each do |status|
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

    %i[pending cancelled].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :create?, :show? do
          it {
            expect(subject).not_to permit(user, trainee_upload)
          }
        end
      end
    end
  end

  context "when the User's organisation is not an HEI Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    %i[pending validated failed in_progress succeeded cancelled].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :show?, :create? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
      end
    end
  end

  context "when the User's organisation is not a Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :with_training_partner_organisation), session: {}) }

    %i[pending validated failed in_progress succeeded cancelled].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :show?, :create? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
      end
    end
  end
end
