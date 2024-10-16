# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    RSpec.describe ImportRows do
      describe "#call" do
        context "when the feature flag is off", "feature_bulk_add_trainees": false do
          let(:trainee_upload) { create(:bulk_update_trainee_upload) }

          it "does not call the `ImportRow` service" do
            expect(ImportRow).not_to receive(:call)
            described_class.call(id: trainee_upload.id)
          end
        end

        context "when the feature flag is on", "feature_bulk_add_trainees": true do
          context "when all rows are valid and can be imported" do
            let(:trainee_upload) { create(:bulk_update_trainee_upload) }

            it "creates 5 trainee records" do
              expect(ImportRow).to receive(:call).exactly(5).times
              described_class.call(id: trainee_upload.id)
            end

            it "sets the status to `succeeded`" do

            end
          end

          context "when some rows are valid and can be imported whilst others are not" do
            let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_errors) }
            subject(:service) { described_class.call(id: trainee_upload.id) }

            it "does not create any trainee records" do

            end

            it "sets the status to `failed`" do

            end
          end
        end
      end
    end
  end
end
