# frozen_string_literal: true

require "rails_helper"

module RecordHeader
  describe View do
    alias_method :component, :page

    let(:trainee) do
      build(:trainee,
            first_names:,
            middle_names:,
            last_name:,
            trn:)
    end

    let(:first_names) { "Dave" }
    let(:middle_names) { "Hendricks" }
    let(:last_name) { "Smith" }
    let(:trn) { nil }

    describe "trainee name" do
      before do
        render_inline(described_class.new(trainee:))
      end

      it "renders the trainee name" do
        expect(component.find(".govuk-heading-l")).to have_text("Dave Hendricks Smith")
      end

      context "where a name is nil" do
        let(:middle_names) { nil }

        it "renders the trainee name" do
          expect(component.find(".govuk-heading-l")).to have_text("Dave Smith")
        end
      end

      context "where a name is an empty string" do
        let(:middle_names) { "" }

        it "renders the trainee name" do
          expect(component.find(".govuk-heading-l")).to have_text("Dave Smith")
        end
      end
    end

    describe "trn" do
      before do
        render_inline(described_class.new(trainee:))
      end

      context "where a trn is present" do
        let(:trn) { "0123456789" }

        it "renders the trn" do
          expect(component.find(".govuk-caption-l")).to have_text(trn)
        end
      end

      context "where a trn is not present" do
        it "does not render the trn" do
          expect(component).not_to have_css(".govuk-caption-l")
        end
      end
    end

    describe "status tag" do
      before do
        allow(StatusTag::View).to receive(:new).with(trainee: trainee, hide_progress_tag: false).and_return(double(render_in: "liverpool"))
        render_inline(described_class.new(trainee:))
      end

      it "is rendered" do
        expect(component).to have_text("liverpool")
      end
    end
  end
end
