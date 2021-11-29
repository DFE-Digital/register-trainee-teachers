# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordActions::View do
  include SummaryHelper

  let(:trainee) { build(:trainee, trait, id: 1) }
  let(:button_text) { "Recommend trainee for QTS" }

  subject { render_inline(described_class.new(trainee)).text }

  shared_examples "no actions" do
    it { is_expected.not_to include("Defer", "withdraw") }
    it { is_expected.not_to include(button_text) }
  end

  shared_examples "no button" do
    it { is_expected.not_to include(button_text) }
  end

  context "trainee state" do
    context "draft" do
      let(:trait) { :draft }

      include_examples "no actions"
    end

    context "submitted for TRN" do
      let(:trait) { :submitted_for_trn }

      it { is_expected.to include("This trainee is pending a TRN", "Defer", "withdraw") }

      include_examples "no button"
    end

    context "TRN received" do
      let(:trait) { :trn_received }

      it { is_expected.to include(button_text, "Defer", "withdraw") }
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

      it { is_expected.to include("This trainee is deferred", "Reinstate", "withdraw") }

      include_examples "no button"
    end

    context "QTS awarded" do
      let(:trait) { :awarded }

      include_examples "no actions"
    end
  end

  context "when course date is in the future" do
    let(:trainee) { build(:trainee, :submitted_for_trn, course_start_date: 1.day.from_now) }

    include_examples "no button"

    it "renders the ITT starts in the future text" do
      expect(subject).to include("The trainee’s ITT starts on #{date_for_summary_view(trainee.course_start_date)}")
    end

    it "withdraw link is hidden" do
      expect(subject).not_to include("withdraw")
    end
  end

  context "when a deffered trainee has not started their ITT" do
    let(:trainee) { build(:trainee, :deferred, commencement_status: :itt_not_yet_started) }

    it "hides the withdraw link" do
      expect(subject).not_to include("Withdraw")
    end
  end

  context "when course date is in the past" do
    let(:trainee) { build(:trainee, :submitted_for_trn, course_start_date: 1.day.ago) }

    it "withdraw link is shown" do
      expect(subject).to include("withdraw")
    end
  end

  context "when the trainee has missing fields" do
    let(:trainee) { build(:trainee, :submitted_for_trn, :course_start_date_in_the_past, commencement_date: nil) }

    subject { render_inline(described_class.new(trainee, has_missing_fields: true)).text }

    include_examples "no button"

    it "renders the missing fields text" do
      expect(subject).to include("This trainee record requires additional details")
    end
  end
end
