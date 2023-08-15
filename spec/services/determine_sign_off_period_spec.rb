# frozen_string_literal: true

require "rails_helper"

describe DetermineSignOffPeriod do
  describe ".call" do
    subject { described_class.call }

    context "during the census sign off period" do
      before do
        allow(Time).to receive_message_chain(:zone, :today, :month).and_return([9, 10].sample) # September, October
      end

      it "returns :census_period" do
        expect(subject).to eq(:census_period)
      end
    end

    context "during the performance profiles sign off period" do
      before do
        allow(Time).to receive_message_chain(:zone, :today, :month).and_return(1) # January
      end

      it "returns :performance_period" do
        expect(subject).to eq(:performance_period)
      end
    end

    context "outside of sign off periods" do
      before do
        allow(Time).to receive_message_chain(:zone, :today, :month).and_return([2, 3, 4, 5, 6, 7, 8, 11, 12].sample) # not Jan or Oct
      end

      it "returns :outside_period" do
        expect(subject).to eq(:outside_period)
      end
    end
  end
end
