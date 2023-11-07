# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe CreateFromHesaJob do
    include ActiveJob::TestHelper

    let(:hesa_trainee) { ApiStubs::HesaApi.new.student_attributes }
    let(:record_source) { RecordSources::HESA_COLLECTION }

    describe "#perform" do
      context "Hesa import is enabled" do
        before { enable_features("hesa_import.sync_collection") }

        it "creates or updates a trainee from a mapped student xml node" do
          expect(Trainees::CreateFromHesa).to receive(:call).with(hesa_trainee:, record_source:)

          described_class.perform_now(hesa_trainee:, record_source:)
        end
      end

      context "Hesa import is disabled" do
        before { disable_features("hesa_import.sync_collection") }

        it "does not create a trainee" do
          expect(Trainees::CreateFromHesa).not_to receive(:call).with(hesa_trainee:, record_source:)

          described_class.perform_now(hesa_trainee:, record_source:)
        end
      end
    end
  end
end
