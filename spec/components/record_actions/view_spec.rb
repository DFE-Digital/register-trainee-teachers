# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordActions::View do
  let(:trainee) { build(:trainee, trait, id: 1) }
  let(:button_text) { "Recommend trainee for QTS" }

  subject { render_inline(described_class.new(trainee)).text }

  context "trainee state" do
    shared_examples "no actions" do
      it { is_expected.not_to include("Defer", "withdraw") }
      it { is_expected.not_to include(button_text) }
    end

    shared_examples "no button" do
      it { is_expected.not_to include(button_text) }
    end

    context "draft" do
      let(:trait) { :draft }

      include_examples "no actions"
    end

    context "submitted for TRN" do
      let(:trait) { :submitted_for_trn }

      it { is_expected.to include("This trainee is pending a TRN", "Defer", "Withdraw") }

      include_examples "no button"
    end

    context "TRN received" do
      let(:trait) { :trn_received }

      it { is_expected.to include(button_text, "Defer", "Withdraw") }
    end

    context "recommended for QTS" do
      let(:trait) { :recommended_for_award }

      include_examples "no actions"
    end

    context "withdrawn" do
      let(:trait) { :withdrawn }

      include_examples "no actions"
    end

    context "deferred" do
      let(:trait) { :deferred }

      it { is_expected.to include("This trainee is deferred", "Reinstate", "Withdraw") }

      include_examples "no button"
    end

    context "QTS awarded" do
      let(:trait) { :awarded }

      include_examples "no actions"
    end
  end

  context "when course date is in the future" do
    let(:trainee) { build(:trainee, :submitted_for_trn, course_start_date: 1.day.from_now) }

    it "withdraw link is hidden" do
      expect(subject).not_to include("Withdraw")
    end
  end

  context "when course date is in the past" do
    let(:trainee) { build(:trainee, :submitted_for_trn, course_start_date: 1.day.ago) }

    it "withdraw link is shown" do
      expect(subject).to include("Withdraw")
    end
  end
end
