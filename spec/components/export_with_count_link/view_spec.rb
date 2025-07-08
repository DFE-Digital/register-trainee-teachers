# frozen_string_literal: true

require "rails_helper"

module ExportWithCountLink
  describe View do
    let(:link_text) { "Export" }
    let(:count_label) { "trainee" }
    let(:href) { "/export" }

    describe "rendered output" do
      before do
        render_inline(described_class.new(link_text:, count:, count_label:, href:))
      end

      context "with 0 records" do
        let(:count) { 0 }

        it "renders the count" do
          expect(page).to have_link("Export (0 trainees)")
        end
      end

      context "with 1 record" do
        let(:count) { 1 }

        it "renders the count" do
          expect(page).to have_link("Export (1 trainee)")
        end
      end

      context "with 2 or more records" do
        let(:count) { 2 }

        it "renders the count" do
          expect(page).to have_link("Export (2 trainees)")
        end
      end
    end

    describe "no record text" do
      before do
        render_inline(described_class.new(link_text: link_text, count: 0, count_label: count_label, href: href)) do |component|
          component.with_no_record_text { "No trainees found" }
        end
      end

      it "renders the no record text" do
        expect(page).to have_content("No trainees found")
      end
    end
  end
end
