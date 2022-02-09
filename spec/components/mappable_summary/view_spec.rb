# frozen_string_literal: true

require "rails_helper"

module MappableSummary
  describe View, type: :component do
    alias_method :component, :page

    before do
      render_inline(described_class.new(trainee: trainee, rows: rows, editable: editable, title: "Star Wars", has_errors: nil))
    end

    describe "when the trainee is editable" do
      let(:editable) { true }
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

    describe "when the record is not editable" do
      let(:editable) { false }
      let(:rows) do
        [
          { field_label: "Course", field_value: nil, action_url: "#path" },
        ]
      end

      let(:trainee) { create(:trainee, :withdrawn) }

      it "renders not provided text without edit links" do
        expect(component).to have_text("Not provided")
        expect(component).not_to have_text("Enter an answer")
        expect(component).not_to have_css(".govuk-link")
        expect(component).not_to have_text("Change")
      end
    end

    describe "#mappable_rows" do
      let(:trainee) { create(:trainee) }
      let(:editable) { true }

      context "mappable_field" do
        let(:rows) do
          [
            { field_value: "History", field_label: "Course", action_url: "#path" },
          ]
        end

        it "returns mappable_field hash" do
          expect(described_class.new(trainee: trainee, editable: editable, rows: rows,
                                     title: "title", has_errors: nil).mappable_rows).to eql([{ key: "Course", value: "History", action_href: "#path", action_text: "Change", action_visually_hidden_text: "course" }])
        end
      end
    end
  end
end
