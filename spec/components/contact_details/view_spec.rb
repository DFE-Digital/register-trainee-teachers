# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactDetails::View do
  context "when no contact details data supplied for existing trainee" do
    before do
      @result ||= render_inline(
        ContactDetails::View.new(data_model: Trainee.new),
      )
    end

    it "renders blank rows for address, email" do
      expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 2)
    end

    it "tells the user that no data has been entered" do
      expect(rendered_component).to have_selector(".govuk-summary-list__value", text: "Not provided", count: 2)
    end
  end

  context "UK based trainee" do
    before do
      mock_trainee.locale_code = "uk"
      @result ||= render_inline(ContactDetails::View.new(data_model: mock_trainee))
    end

    it "renders rows for address, email" do
      expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 2)
    end

    it "renders the address" do
      expect(rendered_component)
        .to have_text([
          mock_trainee.address_line_one,
          mock_trainee.address_line_two,
          mock_trainee.town_city,
          mock_trainee.postcode,
        ].join)
    end

    it "renders the email address" do
      expect(rendered_component)
        .to have_text(mock_trainee.email)
    end
  end

  context "non UK based trainee" do
    before do
      mock_trainee.locale_code = "non_uk"
      mock_trainee.email = "visit@paris.com"
      @result ||= render_inline(ContactDetails::View.new(data_model: mock_trainee))
    end

    it "renders rows for address, email" do
      expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 2)
    end

    it "renders the address" do
      expect(rendered_component)
        .to have_text(mock_trainee.international_address.split(/\r\n+/).join)
    end

    it "renders the email address" do
      expect(rendered_component)
        .to have_text(mock_trainee.email)
    end
  end

private

  def mock_trainee
    @mock_trainee ||= Trainee.new(
      address_line_one: "<a href=\"https://fidusinfosec.com/\">32 Windsor Gardens</a>",
      address_line_two: "Westminster",
      town_city: "London",
      postcode: "EC1 9CP",
      international_address: "Champ de Mars\r\n5 Avenue Anatole",
      email: "Paddington@bear.com",
    )
  end
end
