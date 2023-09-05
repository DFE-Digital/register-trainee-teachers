# frozen_string_literal: true

require "rails_helper"

describe DetermineSignOffPeriod do
  describe ".call" do
    subject { described_class.call }

    let(:current_year) { Time.zone.today.year }
    let(:census_period_range) { Date.new(current_year, 9, 1)..Date.new(current_year, 11, 7) }
    let(:performance_period_range) { Date.new(current_year, 1, 1)..Date.new(current_year, 1, 31) }

    context "with a valid manual override" do
      before do
        allow(Settings).to receive(:sign_off_period).and_return(:census_period)
      end

      it "returns the manual override value" do
        expect(subject).to eq(:census_period)
      end
    end

    context "with an invalid manual override" do
      before do
        allow(Settings).to receive(:sign_off_period).and_return(:invalid_period)
        allow(Sentry).to receive(:capture_exception)
      end

      it "captures the error in Sentry" do
        subject
        expect(Sentry).to have_received(:capture_exception).with(instance_of(StandardError))
      end

      it "defaults back to the calculated behaviour" do
        allow(Time.zone).to receive(:today).and_return(census_period_range.to_a.sample)
        expect(subject).to eq(:census_period)
      end
    end

    context "during the performance profiles sign off period" do
      before do
        random_performance_date = performance_period_range.to_a.sample
        allow(Time.zone).to receive(:today).and_return(random_performance_date)
      end

      it "returns :performance_period" do
        expect(subject).to eq(:performance_period)
      end
    end

    context "outside of sign off periods" do
      before do
        all_dates = [*Date.new(current_year, 1, 1)..Date.new(current_year, 12, 31)]
        outside_dates = all_dates - census_period_range.to_a - performance_period_range.to_a
        allow(Time.zone).to receive(:today).and_return(outside_dates.sample)
      end

      it "returns :outside_period" do
        expect(subject).to eq(:outside_period)
      end
    end
  end
end
