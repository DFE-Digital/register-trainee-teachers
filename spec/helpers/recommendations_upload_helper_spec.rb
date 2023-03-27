# frozen_string_literal: true

require "rails_helper"

describe RecommendationsUploadHelper do
  include RecommendationsUploadHelper

  describe "#qts_or_eyts" do
    let(:qts_row) { create(:bulk_update_recommendations_upload_row, trainee: create(:trainee, :provider_led_postgrad)) }
    let(:eyts_row) { create(:bulk_update_recommendations_upload_row, trainee: create(:trainee, :early_years_postgrad)) }

    subject { qts_or_eyts(rows) }

    context "when all rows relate to QTS trainees" do
      let(:rows) { [qts_row] }

      it "returns QTS" do
        expect(subject).to eq("QTS")
      end
    end

    context "when all rows relate to EYTS trainees" do
      let(:rows) { [eyts_row] }

      it "returns EYTS" do
        expect(subject).to eq("EYTS")
      end
    end

    context "when there are a mixture of rows relating to QTS/EYTS trainees" do
      let(:rows) { [qts_row, eyts_row] }

      it "returns QTS or EYTS" do
        expect(subject).to eq("QTS or EYTS")
      end
    end
  end
end
