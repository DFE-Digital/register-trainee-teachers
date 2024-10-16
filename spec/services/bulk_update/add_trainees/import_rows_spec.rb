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
          before { @original_trainee_count = Trainee.count }

          context "when all rows are valid and can be imported" do
            let(:trainee_upload) { create(:bulk_update_trainee_upload) }
            before do
              allow(ImportRow).to receive(:call).and_return(true)
            end

            it "creates 5 trainee records" do
              expect(ImportRow).to receive(:call).exactly(5).times
              expect(described_class.call(id: trainee_upload.id)).to be(true)

              pending "need to assert that trainee records are created"
              expect(Trainee.count - @original_trainee_count).to eq(5)
            end

            it "sets the status to `succeeded`" do
              described_class.call(id: trainee_upload.id)
              expect(trainee_upload.reload).to be_succeeded
            end
          end

          context "when some rows are valid and can be imported whilst others are not" do
            let(:trainee_upload) { create(:bulk_update_trainee_upload) }
            before do
              allow(ImportRow).to receive(:call).and_return(true, true, true, true, false)
            end

            it "does not create any trainee records" do
              expect(ImportRow).to receive(:call).exactly(5).times
              expect(described_class.call(id: trainee_upload.id)).to be(false)

              expect(Trainee.count).to eq(@original_trainee_count)
            end

            it "sets the status to `failed`" do
              described_class.call(id: trainee_upload.id)
              expect(trainee_upload.reload).to be_failed
            end
          end
        end
      end
    end
  end
end
