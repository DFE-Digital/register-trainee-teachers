# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewDraft::View do
  alias_method :component, :page

  context "renders apply draft component" do
    let(:trainee) { create(:trainee, :with_apply_application) }

    it "uses apply draft trainee" do
      expect(described_class.new(trainee: trainee).component).to be_a(ReviewDraft::ApplyDraft::View)
      expect(described_class.new(trainee: trainee).component).not_to be_a(ReviewDraft::Draft::View)
    end
  end

  context "renders draft component" do
    let(:trainee) { create(:trainee, :draft) }

    it "uses draft trainee" do
      expect(described_class.new(trainee: trainee).component).not_to be_a(ReviewDraft::ApplyDraft::View)
      expect(described_class.new(trainee: trainee).component).to be_a(ReviewDraft::Draft::View)
    end
  end
end
