# frozen_string_literal: true

require "rails_helper"

module Trs
  describe UpdateProfessionalStatus, feature_integrate_with_trs: true do
    let(:trainee) { create(:trainee, :trn_received) }
    let(:client) { class_double(Client) }
    let(:api_response) { {} }

    before do
      allow(Client).to receive(:put).and_return(api_response)
    end

    describe "#call" do
      subject { described_class.call(trainee:) }

      it "submits the correct data to TRS" do
        path = "/v3/persons/#{trainee.trn}/professional-statuses/#{trainee.slug}"
        body = instance_of(String)

        expect(Client).to receive(:put).with(path, body:)
        subject
      end

      it "returns the result of the API call" do
        expect(subject).to eq(api_response)
      end

      context "when the trainee is in an invalid state" do
        before do
          allow(CodeSets::Trs).to receive(:valid_for_update?)
            .with(trainee.state)
            .and_return(false)
        end

        it "doesn't make a request to TRS" do
          expect(Client).not_to receive(:put)
          subject
        end
      end

      context "when the trainee doesn't have a TRN" do
        let(:trainee) { create(:trainee) }

        it "raises an error" do
          expect { subject }.to raise_error(UpdateProfessionalStatus::ProfessionalStatusUpdateMissingTrn)
        end
      end

      context "when the feature flag is disabled", feature_integrate_with_trs: false do
        it "doesn't make a request to TRS" do
          expect(Client).not_to receive(:put)
          subject
        end
      end
    end
  end
end
