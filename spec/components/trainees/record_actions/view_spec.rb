# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::RecordActions::View do
  let(:trainee) { build(:trainee, trait, id: 1) }

  subject { render_inline(described_class.new(trainee)).text }

  context "trainee state" do
    context "draft" do
      let(:trait) { :draft }

      it { is_expected.not_to include("Defer", "withdraw") }
    end

    context "submitted for TRN" do
      let(:trait) { :submitted_for_trn }

      it { is_expected.to include("Defer", "withdraw") }
    end

    context "TRN received" do
      let(:trait) { :trn_received }

      it { is_expected.to include("Defer", "withdraw") }
    end

    context "recommended for QTS" do
      let(:trait) { :recommended_for_qts }

      it { is_expected.not_to include("Defer", "withdraw") }
    end

    context "withdrawn" do
      let(:trait) { :withdrawn }

      it { is_expected.not_to include("Defer", "withdraw") }
    end

    context "QTS awarded" do
      let(:trait) { :qts_awarded }

      it { is_expected.not_to include("Defer", "withdraw") }
    end
  end
end
