# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::RecordActions::View do
  let(:trainee) { build(:trainee, trait, id: 1) }

  subject { render_inline(described_class.new(trainee)).text }

  context "trainee state" do
    context "draft" do
      let(:trait) { :draft }

      it { is_expected.not_to include("Defer", "Withdraw") }
    end

    context "submitted for TRN" do
      let(:trait) { :submitted_for_trn }

      it { is_expected.to include("Defer", "Withdraw") }
    end

    context "TRN received" do
      let(:trait) { :trn_received }

      it { is_expected.to include("Defer", "Withdraw") }
    end

    context "recommended for GTS" do
      let(:trait) { :recommended_for_qts }

      it { is_expected.not_to include("Defer", "Withdraw") }
    end

    context "withdrawn" do
      let(:trait) { :withdrawn }

      it { is_expected.not_to include("Defer", "Withdraw") }
    end

    context "QTS awarded" do
      let(:trait) { :qts_awarded }

      it { is_expected.not_to include("Defer", "Withdraw") }
    end
  end
end
