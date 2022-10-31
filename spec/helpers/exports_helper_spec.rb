# frozen_string_literal: true

require "rails_helper"

describe ExportsHelper do
  include ExportsHelper

  describe "#exceeds_export_limit?" do
    subject { exceeds_export_limit?(user, trainee_count) }

    context "with 100 trainees" do
      let(:trainee_count) { 100 }

      context "as a system admin" do
        let(:user) { build(:user, :system_admin) }

        it "returns false" do
          expect(subject).to be_falsey
        end
      end

      context "as a provider user" do
        let(:user) { build(:user) }

        it "returns false" do
          expect(subject).to be_falsey
        end
      end
    end

    context "with more than 100 trainees" do
      let(:trainee_count) { 101 }

      context "as a system admin" do
        let(:user) { build(:user, :system_admin) }

        it "returns true" do
          expect(subject).to be_truthy
        end
      end

      context "as a provider user" do
        let(:user) { build(:user) }

        it "returns false" do
          expect(subject).to be_falsey
        end
      end
    end
  end
end
