# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe BulkAddTraineesSubmitForm, type: :model do
    subject(:form) { described_class.new(provider:, file:) }

    let(:provider) { create(:provider) }
    let(:user) { create(:user) }
    let(:current_user) { UserWithOrganisationContext.new(user: user, session: {}) }

    context "when user submits a valid upload" do
      it "Queues a TraineeRows job" do
        expect(BulkUpdate::AddTrainees::ImportRowsJob).to receive(:perform_later)
      end
    end
  end
end
