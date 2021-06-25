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

      it { is_expected.to include("This record is pending a TRN", "Defer", "withdraw") }

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

      it { is_expected.to include("This record is deferred", "Reinstate", "withdraw") }

      include_examples "no button"
    end

    context "QTS awarded" do
      let(:trait) { :awarded }

      include_examples "no actions"
    end
  end
end
