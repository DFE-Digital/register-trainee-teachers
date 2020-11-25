# frozen_string_literal: true

require "rails_helper"

module ApplicationRecordCard
  describe View do
    alias_method :component, :page

    before do
      render_inline(described_class.new(record: Trainee.new(id: 1)))
    end

    it "renders 'Draft record' if trainee does not have a first & Last name " do
      expect(component.find("h2")).to have_text("Draft record")
    end

    it "renders 'No subject provided' if there is no subject" do
      expect(component.find(".app-application-card__subject")).to have_text("No subject provided")
    end

    it "renders 'No route provided' if there is no route" do
      expect(component.find(".app-application-card__route")).to have_text("ERROR: No route provided")
    end

    it "renders Status tag" do
      expect(component).to have_selector(".govuk-tag")
    end

    context "when a trainee with all their details filled in" do
      before do
        render_inline(described_class.new(
                        record: Trainee.new(
                          id: 1, first_names: "Teddy",
                          last_name: "Smith",
                          subject: "Designer",
                          record_type: "assessment_only"
                        ),
                      ))
      end

      it "renders trainee name " do
        expect(component.find("h2")).to have_text("Teddy Smith")
      end

      it "renders subject" do
        expect(component.find(".app-application-card__subject")).to have_text("Designer")
      end

      it "renders route if there is no route" do
        expect(component.find(".app-application-card__route")).to have_text("Assessment only")
      end
    end
  end
end
