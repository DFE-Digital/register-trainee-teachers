# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Confirmation::ContactDetails::View do
  alias_method :component, :page

  before do
    render_inline(described_class.new(trainee: trainee))
  end

  context "when no contact details data supplied for existing trainee" do
    let(:trainee) { Trainee.new(id: SecureRandom.uuid) }

    it "renders blank rows for address, email" do
      expect(component).to have_selector(".govuk-summary-list__row", count: 2)
    end

    it "tells the user that no data has been entered" do
      component.find_all(".govuk-summary-list__row").each do |row|
        expect(row.find(".govuk-summary-list__value")).to have_text("Not provided")
      end
    end
  end

  context "UK based trainee" do
    let(:trainee) { build(:trainee) }

    it "renders rows for address, email" do
      expect(component).to have_selector(".govuk-summary-list__row", count: 2)
    end

    it "renders the address" do
      expect(component.find(".govuk-summary-list__row.address .govuk-summary-list__value"))
        .to have_text([
          trainee.address_line_one,
          trainee.address_line_two,
          trainee.town_city,
          trainee.postcode,
        ].join)
    end

    it "renders the email address" do
      expect(component.find(".govuk-summary-list__row.email-address .govuk-summary-list__value"))
        .to have_text(trainee.email)
    end
  end

  context "non UK based trainee" do
    let(:trainee) { build(:trainee, :with_international_address) }

    it "renders rows for address, email" do
      expect(component).to have_selector(".govuk-summary-list__row", count: 2)
    end

    it "renders the address" do
      expect(component.find(".govuk-summary-list__row.address .govuk-summary-list__value"))
        .to have_text(trainee.international_address)
    end

    it "renders the email address" do
      expect(component.find(".govuk-summary-list__row.email-address .govuk-summary-list__value"))
        .to have_text(trainee.email)
    end
  end
end
