# frozen_string_literal: true

require "rails_helper"

describe EmailRateLimiter do
  describe ".call" do
    subject { described_class.call(email:, scope:) }

    let(:email) { "user@example.com" }
    let(:scope) { :requests }
    let(:memory_store) { ActiveSupport::Cache::MemoryStore.new }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
    end

    context "when within the limit" do
      it "returns false" do
        2.times do
          expect(described_class.call(email:, scope:)).to be(false)
        end
      end
    end

    context "when the limit is exceeded" do
      before do
        2.times { described_class.call(email:, scope:) }
      end

      it "returns true" do
        expect(subject).to be(true)
      end

      it "returns true for the same email with different casing" do
        expect(described_class.call(email: "USER@example.com", scope: scope)).to be(true)
      end

      it "returns false for a different email" do
        expect(described_class.call(email: "other@example.com", scope: scope)).to be(false)
      end

      it "returns false for the same email in a different scope" do
        expect(described_class.call(email: email, scope: :verifications)).to be(false)
      end

      it "returns false once the period has passed" do
        Timecop.travel(61.seconds.from_now) do
          expect(subject).to be(false)
        end
      end
    end

    context "with the verifications scope" do
      let(:scope) { :verifications }

      it "allows 5 attempts before returning true" do
        5.times do
          expect(described_class.call(email:, scope:)).to be(false)
        end

        expect(subject).to be(true)
      end
    end

    context "when the cache is a null store" do
      let(:memory_store) { ActiveSupport::Cache::NullStore.new }

      it "returns false" do
        3.times do
          expect(described_class.call(email:, scope:)).to be(false)
        end
      end
    end
  end
end
