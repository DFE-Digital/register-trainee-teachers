# frozen_string_literal: true

require "rails_helper"

module LevelFiveDeclaration
  describe View do
    let(:level_five_qualification) { true }
    let(:trainee) do
      create(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: level_five_qualification,
                                                                   itt_start_date: Date.new(2026, 9, 1), itt_end_date: Date.new(2028, 9, 1))
    end

    before { render_inline(View.new(data_model: trainee, editable: true)) }

    def row(key)
      page.find(".govuk-summary-list__row", text: key)
    end

    it "shows Year 2 entry and the 2-year course duration" do
      expect(row("Year 2 entry")).to have_text("Yes")
      expect(row("Course duration")).to have_text("2 years")
    end

    it "shows the apprenticeship dates, changed in course details" do
      expect(row("Course start date")).to have_text("1 September 2026")
      expect(row("Expected end date")).to have_text("1 September 2028")
      expect(row("Expected end date")).to have_link("Change", href: "/trainees/#{trainee.slug}/course-details/edit")
    end

    context "with standard entry" do
      let(:level_five_qualification) { false }

      it { expect(row("Course duration")).to have_text("3 years (33 months)") }
    end
  end
end
