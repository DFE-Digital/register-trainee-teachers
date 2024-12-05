# frozen_string_literal: true

require "rails_helper"

describe DetermineSignOffPeriod do
  describe ".call" do
    subject { described_class.call(previous_academic_cycle: academic_cycle) }

    let(:academic_cycle) { create(:academic_cycle) }

    before do
      allow(Settings).to receive(:sign_off_period).and_return(nil)
    end

    current_year = Time.zone.today.year
    census_period_range = [*Date.new(current_year, 9, 1)..Date.new(current_year, 11, 7)]
    jan_to_feb_range = Date.new(Time.zone.today.year, 1, 1)..Date.new(Time.zone.today.year, 2, 7)
    december_range = Date.new(Time.zone.today.year, 12, 1)..Date.new(Time.zone.today.year, 12, 31)
    performance_period_range = [*jan_to_feb_range, *december_range]
    all_dates = [*Date.new(current_year, 1, 1)..Date.new(current_year, 12, 31)]
    outside_dates = all_dates - census_period_range - performance_period_range

    %i[census_period performance_period outside_period].each do |sign_off_period|
      context "with a valid manual override" do
        before do
          allow(Settings).to receive(:sign_off_period).and_return(sign_off_period)
        end

        it "returns the manual override value #{sign_off_period}" do
          expect(subject).to eq(sign_off_period)
        end
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
    end

    census_period_range.each do |census_date|
      context "on #{census_date} the census sign off period" do
        before do
          allow(Time.zone).to receive(:today).and_return(census_date)
        end

        it "returns :census_period" do
          expect(subject).to eq(:census_period)
        end
      end
    end

    performance_period_range.each do |performance_date|
      context "on #{performance_date} the performance profiles sign off period" do
        before do
          allow(Time.zone).to receive(:today).and_return(performance_date)
          allow(academic_cycle).to receive(:in_performance_profile_range?).with(performance_date).and_return(true)
        end

        it "returns :performance_period" do
          expect(subject).to eq(:performance_period)
        end
      end
    end

    outside_dates.each do |outside_date|
      context "the #{outside_date} is outside of sign off periods" do
        before do
          allow(Time.zone).to receive(:today).and_return(outside_date)
        end

        it "returns :outside_period" do
          expect(subject).to eq(:outside_period)
        end
      end
    end
  end
end
