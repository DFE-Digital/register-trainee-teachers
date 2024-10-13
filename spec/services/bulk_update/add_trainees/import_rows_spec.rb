# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    RSpec.describe ImportRows do
      describe "#call" do
        context "when all rows are valid and can be imported" do
          let(:trainee_upload) { create(:bulk_update_trainee_upload) }
          subject(:service) { described_class.call(id: trainee_upload.id) }

          it "creates 3 trainee records" do

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
