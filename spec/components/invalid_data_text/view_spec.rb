# frozen_string_literal: true

require "rails_helper"

module InvalidDataText
  describe View, type: :component do
    before do
      render_inline(described_class.new(form_section:, degree_form:))
    end

    let(:degree) { trainee.degrees.first }
    let(:degree_form) { instance_double(DegreeForm, errors: OpenStruct.new(any?: nil), degree: degree) }

    context "when there is invalid data for an apply trainee" do
      let(:trainee) { create(:trainee, :with_invalid_apply_application) }
      let(:form_section) { :institution }

      it "renders the correct css" do
        expect(page).to have_css(".app-inset-text__title")
        expect(page).to have_text("The trainee entered ‘Unknown institution’, which was not recognised. You need to search for the closest match.")
      end
    end

    context "when there is valid data for an apply trainee" do
      let(:trainee) { create(:trainee, :with_apply_application) }
      let(:form_section) { :subject }

      it "does not render the inset css" do
        expect(page).not_to have_css(".app-inset-text__title")
      end
    end
  end
end
