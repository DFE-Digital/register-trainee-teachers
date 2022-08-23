# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncStatesJob do
    let!(:trainee) { create(:trainee, state, :imported_from_hesa) }

    before do
      enable_features(:integrate_with_dqt)
    end

    context "when the Register trainee is not trn_received" do
      let(:state) { "awarded" }

      it "is a no-op" do
        expect(Dqt::SyncState).not_to receive(:call)

        described_class.perform_now
      end
    end

    context "when the Register trainee is trn_received" do
      let(:state) { "trn_received" }

      it "calls the Dqt::Sync service" do
        expect(Dqt::SyncState).to receive(:call).with(trainee: trainee)

        described_class.perform_now
      end

      context "but not from HESA" do
        before do
          trainee.update!(hesa_id: nil)
        end

        it "is a no-op" do
          expect(Dqt::SyncState).not_to receive(:call)

          described_class.perform_now
        end
      end

      context "but the TRN is not 7-digits" do
        before do
          trainee.update!(trn: "123456")
        end

        it "is a no-op" do
          expect(Dqt::SyncState).not_to receive(:call)

          described_class.perform_now
        end
      end
    end
  end
end
