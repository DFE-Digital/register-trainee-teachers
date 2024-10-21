# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    RSpec.describe ImportRow do
      let(:current_provider) { create(:provider) }
      let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees.csv").read }
      let(:parsed_csv) { CSV.parse(csv, headers: true) }
      let!(:nationality) { create(:nationality, :british) }

      describe "#call" do
        context "when the row is invalid" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_two_errors.csv").read }
          let(:row) { parsed_csv.first }

          it "does not create a trainee record" do
            original_count = Trainee.count
            result = described_class.call(row:,  current_provider:)
            expect(result.success).to be(false)
            expect(Trainee.count).to eql(original_count)
          end
        end

        context "when the row is valid" do
          let(:row) { parsed_csv.first }

          it "creates a trainee record" do
            original_count = Trainee.count
            result = described_class.call(row:,  current_provider:)
            expect(result.success).to be(true)
            expect(Trainee.count - original_count).to eql(1)
          end
        end
      end
    end
  end
end
