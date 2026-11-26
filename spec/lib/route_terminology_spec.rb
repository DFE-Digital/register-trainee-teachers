# frozen_string_literal: true

require "rails_helper"

describe RouteTerminology do
  let(:eytda) { build(:trainee, :early_years_teacher_degree_apprenticeship) }
  let(:salaried) { build(:trainee, :early_years_salaried) }

  describe ".t" do
    it "gives the EYTDA wording for an EYTDA trainee" do
      expect(described_class.t(eytda, "components.course_detail.itt_start_date")).to eq("Course start date")
    end

    it "gives today's wording on other routes" do
      expect(described_class.t(salaried, "components.course_detail.itt_start_date")).to eq("ITT start date")
    end

    it "gives today's wording when there's no EYTDA version" do
      expect(described_class.t(eytda, "components.course_detail.subject")).to eq("Subject")
    end

    it "passes on interpolations" do
      text = described_class.t(eytda, "views.forms.start_dates.trainee_start_date.hint", itt_start_date: "01 09 2026")
      expect(text).to eq("Their course started on 01 09 2026")
    end
  end

  describe ".error_type" do
    it { expect(described_class.error_type(eytda, :blank)).to eq(:eytda_blank) }
    it { expect(described_class.error_type(salaried, :blank)).to eq(:blank) }
  end
end
