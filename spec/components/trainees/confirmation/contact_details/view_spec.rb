require "rails_helper"

RSpec.describe Trainees::Confirmation::ContactDetails::View do
  alias_method :component, :page

  context "when no contact details data supplied for existing trainee" do
    before(:all) do
      @result ||= render_inline(Trainees::Confirmation::ContactDetails::View.new(trainee: Trainee.new(id: 1)))
    end

    it "renders blank rows for address, email, telephone" do
      expect(component).to have_selector(".govuk-summary-list__row", count: 3)
    end

    it "tells the user that no data has been entered" do
      component.find_all(".govuk-summary-list__row").each do |row|
        expect(row.find(".govuk-summary-list__value")).to have_text("Not provided")
      end
    end
  end

  context "UK based trainee" do
    before(:all) do
      mock_trainee.locale_code = "uk"
      @result ||= render_inline(Trainees::Confirmation::ContactDetails::View.new(trainee: mock_trainee))
    end

    it "renders rows for address, email, telephone" do
      expect(component).to have_selector(".govuk-summary-list__row", count: 3)
    end

    it "renders the address" do
      expect(component.find(".govuk-summary-list__row.address .govuk-summary-list__value"))
        .to have_text([
          mock_trainee.address_line_one,
          mock_trainee.address_line_two,
          mock_trainee.town_city,
          mock_trainee.postcode,
        ].join)
    end

    it "renders the phone number" do
      expect(component.find(".govuk-summary-list__row.phone-number .govuk-summary-list__value"))
        .to have_text(mock_trainee.phone_number)
    end

    it "renders the email address" do
      expect(component.find(".govuk-summary-list__row.email-address .govuk-summary-list__value"))
        .to have_text(mock_trainee.email)
    end
  end

  context "non UK based trainee" do
    before(:all) do
      mock_trainee.locale_code = "non_uk"
      mock_trainee.phone_number = "+33 (0)8 92 70 12 39"
      mock_trainee.email = "visit@paris.com"
      @result ||= render_inline(Trainees::Confirmation::ContactDetails::View.new(trainee: mock_trainee))
    end

    it "renders rows for address, email, telephone" do
      expect(component).to have_selector(".govuk-summary-list__row", count: 3)
    end

    it "renders the address" do
      expect(component.find(".govuk-summary-list__row.address .govuk-summary-list__value"))
        .to have_text(mock_trainee.international_address.split(/\r\n+/).join)
    end

    it "renders the phone number" do
      expect(component.find(".govuk-summary-list__row.phone-number .govuk-summary-list__value"))
        .to have_text(mock_trainee.phone_number)
    end

    it "renders the email address" do
      expect(component.find(".govuk-summary-list__row.email-address .govuk-summary-list__value"))
        .to have_text(mock_trainee.email)
    end
  end

private

  def mock_trainee
    @mock_trainee ||= Trainee.new(id: 1,
                                  address_line_one: "32 Windsor Gardens",
                                  address_line_two: "Westminster",
                                  town_city: "London",
                                  postcode: "EC1 9CP",
                                  international_address: "Champ de Mars\r\n5 Avenue Anatole France\r\n75007 Paris\r\nFrance",
                                  phone_number: "0207 123 4567",
                                  email: "Paddington@bear.com")
  end
end
