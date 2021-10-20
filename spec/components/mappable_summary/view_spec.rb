# frozen_string_literal: true

require "rails_helper"

module MappableSummary
  describe View, type: :component do
    alias_method :component, :page

    before do
      render_inline(described_class.new(trainee: trainee, rows: rows, system_admin: system_admin, title: "Star Wars", has_errors: nil))
    end

    describe "when the user is a system admin" do
      let(:system_admin) { true }
      let(:trainee) { create(:trainee, :withdrawn) }

      context "closed trainee records are editable" do
        let(:rows) do
          [
            { field_label: "Course", field_value: nil, action_url: "#path" },
          ]
        end

        it "renders missing data markup" do
          expect(component).to have_text("Enter an answer")
          expect(component).to have_text("Course is missing")
          expect(component).to have_css(".govuk-link")
          expect(component).not_to have_text("Change")
        end
      end

      context "does not render missing data markup" do
        let(:rows) do
          [
            { field_label: "Course details", field_value: "History", action_url: "#path" },
          ]
        end

        it "renders the change link" do
          expect(component).to have_text("Change")
        end
      end
    end

    describe "when the user is not a system admin" do
      let(:system_admin) { false }
      let(:rows) do
        [
          { field_label: "Course", field_value: nil, action_url: "#path" },
        ]
      end

      context "closed trainee records not editable" do
        let(:trainee) { create(:trainee, :withdrawn) }

        it "renders missing data markup without edit links" do
          expect(component).to have_text("Course is missing")
          expect(component).not_to have_text("Enter an answer")
          expect(component).not_to have_css(".govuk-link")
          expect(component).not_to have_text("Change")
        end
      end

      context "open trainee records are editable" do
        let(:trainee) { create(:trainee, :submitted_for_trn) }

        it "renders missing data markup with edit link" do
          expect(component).to have_text("Course is missing")
          expect(component).to have_text("Enter an answer")
          expect(component).to have_css(".govuk-link")
        end
      end
    end

    describe "#mappable_rows" do
      let(:trainee) { create(:trainee) }
      let(:system_admin) { false }

      context "mappable_field" do
        let(:rows) do
          [
            { field_value: "History", field_label: "Course", action_url: "#path" },
          ]
        end

        it "returns mappable_field hash" do
          expect(described_class.new(trainee: trainee, system_admin: system_admin, rows: rows,
                                     title: "title", has_errors: nil).mappable_rows).to eql([{ key: "Course", value: "History", action_href: "#path", action_text: "Change", action_visually_hidden_text: "course" }])
        end
      end
    end
  end
end
