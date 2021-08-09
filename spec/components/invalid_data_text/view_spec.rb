# frozen_string_literal: true

require "rails_helper"

module InvalidDataText
  describe View, type: :component do
    before do
      render_inline(described_class.new(degree: degree, form_section: form_section))
    end

    let(:degree) { trainee.degrees.first }

    context "when there is invalid data for an apply trainee" do
      let(:trainee) { create(:trainee, :with_invalid_apply_application) }
      let(:form_section) { :institution }

      it "renders the correct css" do
        expect(rendered_component).to have_css(".app-inset-text__title")
        expect(rendered_component).to have_text("The trainee entered ‘University of Warwick’. You need to search for the closest match.")
      end
    end

    context "when there is valid data for an apply trainee" do
      let(:trainee) { create(:trainee, :with_apply_application) }
      let(:form_section) { :subject }

      it "renders the correct css" do
        expect(rendered_component).to have_css(".govuk-hint")
        expect(rendered_component).to have_text(nil)
      end
    end
  end
end
