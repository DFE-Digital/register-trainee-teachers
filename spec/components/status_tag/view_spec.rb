# frozen_string_literal: true

require "rails_helper"

describe StatusTag::View do
  before do
    render_inline(described_class.new(trainee:))
  end

  context "with a trainee recommended for EYTS" do
    let(:trainee) { build(:trainee, :early_years_undergrad, :recommended_for_award) }

    it "renders the correct status" do
      expect(rendered_content).to have_text("EYTS recommended")
    end
  end

  context "with a trainee awarded EYTS" do
    let(:trainee) { build(:trainee, :early_years_undergrad, :awarded) }

    it "renders the correct status" do
      expect(rendered_content).to have_text("EYTS awarded")
    end
  end

  context "with a trainee teacher degree apprenticeship recommended for QTS" do
    let(:trainee) { build(:trainee, :teacher_degree_apprenticeship, :recommended_for_award) }

    it "renders the correct status" do
      expect(rendered_content).to have_text("Selected for QTS")
    end
  end

  context "with a trainee teacher degree apprenticeship awarded QTS" do
    let(:trainee) { build(:trainee, :teacher_degree_apprenticeship, :awarded) }

    it "renders the correct status" do
      expect(rendered_content).to have_text("QTS awarded")
    end
  end

  context "with a trainee recommended for QTS" do
    let(:trainee) { build(:trainee, :recommended_for_award) }

    it "renders the correct status" do
      expect(rendered_content).to have_text("Selected for QTS")
    end
  end

  context "with a trainee awarded QTS" do
    let(:trainee) { build(:trainee, :awarded) }

    it "renders the correct status" do
      expect(rendered_content).to have_text("QTS awarded")
    end
  end

  context "with a trainee that's not submission ready" do
    let(:trainee) { build(:trainee, :trn_received, :not_submission_ready) }

    it "renders the correct status" do
      expect(rendered_content).to have_text("Incomplete")
    end
  end

  context "when hide_progress_tag is true" do
    before do
      render_inline(described_class.new(trainee: trainee, hide_progress_tag: true))
    end

    let(:trainee) { build(:trainee, :trn_received, :not_submission_ready) }

    it "does not render the incomplete progress tag" do
      expect(rendered_content).not_to have_text("Incomplete")
    end
  end
end
