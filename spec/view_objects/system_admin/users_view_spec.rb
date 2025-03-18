# frozen_string_literal: true

require "rails_helper"

describe SystemAdmin::UsersView do
  let(:provider) { create(:provider) }
  let(:user) { provider.users.first }

  subject { described_class.new(provider) }

  before do
    user
  end

  describe "#users" do
    it "returns the provider's users" do
      expect(subject.users.count).to eq 1
      expect(subject.users.first).to eq user
    end

    context "soft deleted" do
      before do
        user.update(discarded_at: Faker::Time.backward(days: 1).utc)
      end

      it "doesnt return users" do
        expect(subject.users.count).not_to eq 1
        expect(subject.users.first).not_to eq user
      end
    end
  end
end
