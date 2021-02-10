# frozen_string_literal: true

require "rails_helper"

module MissingDetails
  describe View do
    alias_method :component, :page

    let(:trainee) { build(:trainee) }

    renders_not_started_title = "renders the not started title"
    renders_start_link = "renders the start link"
    start_section = start_section
    renders_not_complete_title = "renders_not_complete_title"
    renders_continue_link = "renders the continue_link"
    continue_section = continue_section

    before do
      render_inline(described_class.new(section: section, progress: progress, trainee: trainee))
    end

    context "when personal details not started" do
      let(:progress) { nil }
      let(:section) { :personal_details }

      it renders_not_started_title do
        expect(component).to have_text("Personal details not started")
      end

      it renders_start_link do
        expect(component).to have_link(start_section)
      end

      it "renders the correct css classes" do
        expect(component).to have_css(".app-inset-text--important .govuk-link")
        expect(component).to have_css(".app-inset-text--narrow-border")
      end
    end

    context "when personal details not completed" do
      let(:progress) { false }
      let(:section) { :personal_details }

      it renders_not_complete_title do
        expect(component).to have_text("Personal details not marked as complete")
      end

      it renders_continue_link do
        expect(component).to have_link(continue_section)
      end
    end

    context "when contact details not started" do
      let(:progress) { nil }
      let(:section) { :contact_details }

      it renders_not_started_title do
        expect(component).to have_text("Contact details not started")
      end

      it renders_start_link do
        expect(component).to have_link(start_section)
      end
    end

    context "when contact details not completed" do
      let(:progress) { false }
      let(:section) { :contact_details }

      it renders_not_complete_title do
        expect(component).to have_text("Contact details not marked as complete")
      end

      it renders_continue_link do
        expect(component).to have_link(continue_section)
      end
    end

    context "when diversity information not started" do
      let(:progress) { nil }
      let(:section) { :diversity }

      it renders_not_started_title do
        expect(component).to have_text("Diversity information not started")
      end

      it renders_start_link do
        expect(component).to have_link(start_section)
      end
    end

    context "when diversity information not completed" do
      let(:progress) { false }
      let(:section) { :diversity }

      it renders_not_complete_title do
        expect(component).to have_text("Diversity information not marked as complete")
      end

      it renders_continue_link do
        expect(component).to have_link(continue_section)
      end
    end

    context "when degree details not started" do
      let(:progress) { nil }
      let(:section) { :degrees }

      it renders_not_started_title do
        expect(component).to have_text("Degree details not started")
      end

      it renders_start_link do
        expect(component).to have_link(start_section)
      end
    end

    context "when degree details not completed" do
      let(:progress) { false }
      let(:section) { :degrees }

      it renders_not_complete_title do
        expect(component).to have_text("Degree details not marked as complete")
      end

      it renders_continue_link do
        expect(component).to have_link(continue_section)
      end
    end

    context "when programme details not started" do
      let(:progress) { nil }
      let(:section) { :programme_details }

      it renders_not_started_title do
        expect(component).to have_text("Programme details not started")
      end

      it renders_start_link do
        expect(component).to have_link(start_section)
      end
    end

    context "when programme details not completed" do
      let(:progress) { false }
      let(:section) { :programme_details }

      it renders_not_complete_title do
        expect(component).to have_text("Programme details not marked as complete")
      end

      it renders_continue_link do
        expect(component).to have_link(continue_section)
      end
    end
  end
end
