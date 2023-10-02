# frozen_string_literal: true

require "rails_helper"

describe ContactDetails::View do
  context "when no contact details data supplied for existing trainee" do
    before do
      @result ||= render_inline(
        ContactDetails::View.new(data_model: Trainee.new, editable: true),
      )
    end

    it "renders a blank row for email" do
      expect(rendered_component).to have_css(".govuk-summary-list__row", count: 1)
    end

    it "tells the user that the email is missing" do
      expect(rendered_component).to have_css(".govuk-summary-list__value", text: t("components.confirmation.missing"), count: 1)
    end
  end

  context "UK based trainee" do
    before do
      @result ||= render_inline(ContactDetails::View.new(data_model: mock_trainee, editable: true))
    end

    it "renders rows for email" do
      expect(rendered_component).to have_css(".govuk-summary-list__row", count: 1)
    end

    it "renders the contact details change link" do
      expect(rendered_component)
        .to have_link(t("change"), href: "/trainees/#{mock_trainee.slug}/contact-details/edit")
    end

    it "renders the email address" do
      expect(rendered_component)
        .to have_text(mock_trainee.email)
    end
  end

  context "HESA trainee" do
    before do
      mock_trainee.hesa_id = "XXX"
      @result ||= render_inline(ContactDetails::View.new(data_model: mock_trainee))
    end

    it "does not render rows for address, only email" do
      expect(rendered_component).to have_css(".govuk-summary-list__row", count: 1)
    end

    it "renders the email address" do
      expect(rendered_component).to have_text(mock_trainee.email)
    end
  end

private

  def mock_trainee
    @mock_trainee ||= Trainee.new(email: "Paddington@bear.com")
  end
end
