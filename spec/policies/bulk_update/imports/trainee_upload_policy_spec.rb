# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::Imports::TraineeUploadPolicy, type: :policy do
  subject { described_class }

  it { is_expected.to be < BulkUpdate::TraineeUploads::BasePolicy }

  context "when the User's organisation is an HEI Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :hei), session: {}) }

    context "when the upload is uploaded" do
      let(:trainee_upload) { build(:bulk_update_trainee_upload, :uploaded) }

      permissions :create? do
        it { is_expected.to permit(user, trainee_upload) }
      end
    end

    %i[pending validated in_progress succeeded cancelled failed].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :create? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
      end
    end
  end

  context "when the User's organisation is not an HEI Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    %i[uploaded pending validated in_progress succeeded cancelled failed].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :create? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
      end
    end
  end

  context "when the User's organisation is not a Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :with_lead_partner_organisation), session: {}) }
    let(:trainee_upload) { build(:bulk_update_trainee_upload, provider: user.providers.first) }

    %i[uploaded pending validated in_progress succeeded failed cancelled].each do |status|
      context "when the upload is #{status}" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

        permissions :create? do
          it { is_expected.not_to permit(user, trainee_upload) }
        end
      end
    end
  end

  context "when the User's organisation is a previously accredited HEI lead partner" do
    let(:lead_partner) { create(:lead_partner, :hei) }
    let(:user) { UserWithOrganisationContext.new(user: create(:user, providers: [lead_partner.provider]), session: {}) }
    let(:trainee_upload) { build(:bulk_update_trainee_upload, provider: user.providers.first) }

    context "and the environment is 'csv-sandbox'" do
      context "when the upload is uploaded" do
        let(:trainee_upload) { build(:bulk_update_trainee_upload, :uploaded) }

        permissions :create? do
          it "permits the user" do
            allow(Rails.env).to receive(:in?).with(%w[csv-sandbox]).and_return(true)
            expect(subject).to permit(user, trainee_upload)
          end
        end
      end

      %i[pending validated in_progress succeeded cancelled failed].each do |status|
        context "when the upload is #{status}" do
          let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

          permissions :create? do
            it "does not permit the user" do
              allow(Rails.env).to receive(:in?).with(%w[csv-sandbox]).and_return(true)
              expect(subject).not_to permit(user, trainee_upload)
            end
          end
        end
      end
    end

    context "and the environment is not 'csv-sandbox'" do
      %i[uploaded pending validated in_progress succeeded cancelled failed].each do |status|
        context "and the upload is #{status}" do
          let(:trainee_upload) { build(:bulk_update_trainee_upload, status) }

          permissions :create? do
            it "does not permit the user" do
              allow(Rails.env).to receive(:in?).with(%w[csv-sandbox]).and_return(false)
              expect(subject).not_to permit(user, trainee_upload)
            end
          end
        end
      end
    end
  end
end
