# frozen_string_literal: true

require "rails_helper"

RSpec.describe TimeHelpers do
  include TimeHelpers
  include ActiveSupport::Testing::TimeHelpers

  describe "#in_exact_time" do
    let(:from) { Date.new(2026, 1, 1) }

    context "when datetime is in the past" do
      it "returns nil" do
        expect(in_exact_time(from - 1.day, from)).to be_nil
      end
    end

    context "when datetime equals from" do
      it "returns nil" do
        expect(in_exact_time(from, from)).to be_nil
      end
    end

    context "when datetime is in days" do
      it "returns 'in 1 day' for singular" do
        expect(in_exact_time(from + 1.day, from)).to eq("in 1 day")
      end

      it "returns 'in 2 days' for plural" do
        expect(in_exact_time(from + 2.days, from)).to eq("in 2 days")
      end
    end

    context "when datetime is in weeks" do
      it "returns 'in 1 week' for singular" do
        expect(in_exact_time(from + 7.days, from)).to eq("in 1 week")
      end

      it "returns 'in 2 weeks' for plural" do
        expect(in_exact_time(from + 14.days, from)).to eq("in 2 weeks")
      end
    end

    context "when datetime is in months" do
      it "returns 'in 1 month' for singular" do
        expect(in_exact_time(from + 1.month, from)).to eq("in 1 month")
      end

      it "returns 'in 2 months' for plural" do
        expect(in_exact_time(from + 2.months, from)).to eq("in 2 months")
      end
    end

    context "when using default from time" do
      it "uses Time.current as the default" do
        travel_to from do
          expect(in_exact_time(from + 7.days)).to eq("in 1 week")
        end
      end
    end
  end
end
