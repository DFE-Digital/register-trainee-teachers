# frozen_string_literal: true

require "rails_helper"

describe EmailRateLimiter do
  describe ".call" do
    subject { described_class.call(email:) }

    let(:email) { "user@example.com" }
    let(:memory_store) { ActiveSupport::Cache::MemoryStore.new }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
    end

    context "when within the limit" do
      it "returns false" do
        2.times do
          expect(described_class.call(email:)).to be(false)
        end
      end
    end

    context "when the limit is exceeded" do
      before do
        2.times { described_class.call(email:) }
      end

      it "returns true" do
        expect(subject).to be(true)
      end

      it "returns true for the same email with different casing" do
        expect(described_class.call(email: "USER@example.com")).to be(true)
      end

      it "returns false for a different email" do
        expect(described_class.call(email: "other@example.com")).to be(false)
      end

      it "returns false once the period has passed" do
        Timecop.travel(61.seconds.from_now) do
          expect(subject).to be(false)
        end
      end
    end

    context "when the cache is a null store" do
      let(:memory_store) { ActiveSupport::Cache::NullStore.new }

      it "returns false" do
        3.times do
          expect(described_class.call(email:)).to be(false)
        end
      end
    end
  end
end
