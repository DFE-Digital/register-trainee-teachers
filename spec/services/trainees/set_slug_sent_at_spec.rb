# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SetSlugSentAt do
    let(:trainee) { create(:trainee) }

    around do |example|
      Timecop.freeze { example.run }
    end

    context "when the `slug_sent_to_trs_at` has not previously been set" do
      it "sets the `slug_sent_to_trs_at` attribute to the current datetime" do
        described_class.call(trainee:)
        expect(trainee.slug_sent_to_trs_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    context "when the `slug_sent_to_trs_at` has previously been set" do
      let(:trainee) { create(:trainee, slug_sent_to_trs_at: 1.day.ago) }

      it "updates the `slug_sent_to_trs_at` attribute" do
        described_class.call(trainee:)
        expect(trainee.slug_sent_to_trs_at).to be_within(1.second).of(Time.zone.now)
      end
    end
  end
end
