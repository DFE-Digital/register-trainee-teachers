# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::Details::TraineeUploadPolicy, type: :policy do
  subject { described_class }

  let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

  it { is_expected.to be < BulkUpdate::TraineeUploads::BasePolicy }

  context "when the User's organisation is an HEI Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :hei), session: {}) }

    describe "#show" do
      context "when the upload is succeeded" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, :succeeded) }

        permissions :show? do
          it { is_expected.to permit(user, trainee_upload) }
        end
      end

      %i[pending validated in_progress cancelled failed].each do |status|
        context "when the upload is #{status}" do
          let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

          permissions :show? do
            it { is_expected.not_to permit(user, trainee_upload) }
          end
        end
      end
    end

    context "when the User's organisation is not an HEI Provider" do
      let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

      %i[pending validated in_progress succeeded cancelled failed].each do |status|
        context "when the upload is #{status}" do
          let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

          permissions :show? do
            it { is_expected.not_to permit(user, trainee_upload) }
          end
        end
      end
    end
  end
end
