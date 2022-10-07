# frozen_string_literal: true

require "rails_helper"

module DataMigrations
  describe BackfillHesaTrnSubmissions do
    subject(:service) { described_class }
    let(:trainee) { create(:trainee, :imported_from_hesa, :trn_received) }
    let(:non_hesa_trainee) { create(:trainee) }
    let(:payload) do
      <<~TEXT
        UKPRN,HUSID,TRN
        #{[trainee.provider.ukprn, trainee.hesa_id, trainee.trn].join(',')}
      TEXT
    end
    let!(:submission) { create(:hesa_trn_submission, payload: payload) }

    describe "#call" do
      it "adds the hesa_trn_submission.id to the trainee" do
        expect(trainee.hesa_trn_submission_id).to be_nil
        expect(non_hesa_trainee.hesa_trn_submission_id).to be_nil
        service.call
        expect(trainee.reload.hesa_trn_submission_id).to eql submission.id
        expect(non_hesa_trainee.reload.hesa_trn_submission_id).to be_nil
      end
    end
  end
end
