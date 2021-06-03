# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatusTag::View do
  alias_method :component, :page

  before do
    render_inline(described_class.new(trainee: trainee))
  end

  context "with a trainee recommended for EYTS" do
    let(:trainee) { create(:trainee, :early_years_undergrad, :recommended_for_award) }

    it "renders the correct status" do
      expect(component).to have_text("EYTS recommended")
    end
  end

  context "with a trainee awarded EYTS" do
    let(:trainee) { create(:trainee, :early_years_undergrad, :awarded) }

    it "renders the correct status" do
      expect(component).to have_text("EYTS awarded")
    end
  end

  context "with a trainee recommended for QTS" do
    let(:trainee) { create(:trainee, :recommended_for_award) }

    it "renders the correct status" do
      expect(component).to have_text("QTS recommended")
    end
  end

  context "with a trainee awarded QTS" do
    let(:trainee) { create(:trainee, :awarded) }

    it "renders the correct status" do
      expect(component).to have_text("QTS awarded")
    end
  end
end
