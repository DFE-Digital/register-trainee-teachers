# frozen_string_literal: true

require "rails_helper"

module InvalidDataText
  describe View, type: :component do
    alias_method :component, :page

    before do
      render_inline(described_class.new(trainee: trainee, form_section: form_section))
    end

    context "when there is invalid data for an apply trainee" do
      let(:trainee) { create(:trainee, :with_apply_application) }
      let(:form_section) { :institution }

      it "renders the correct css" do
        expect(component).to have_css(".app-inset-text__title")
        expect(component).to have_text("The trainee entered ‘Southampton University’. You need to search for the closest match.")
      end
    end

    context "when there is valid data for an apply trainee" do
      let(:trainee) { create(:trainee, :with_apply_application) }
      let(:form_section) { :subject }

      it "renders the correct css" do
        expect(component).to have_css(".govuk-hint")
        expect(component).to have_text(nil)
      end
    end
  end
end
