# frozen_string_literal: true

require "rails_helper"

describe ContactDetailsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee, locale_code: nil) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params, form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:locale_code) }
    it { is_expected.to validate_presence_of(:email) }

    context "empty form data" do
      let(:params) do
        {
          "address_line_two" => "",
          "international_address" => "",
          "email" => "",
          "address_line_one" => "",
          "town_city" => "",
          "postcode" => "",
        }
      end

      before do
        subject.valid?
      end

      it "returns 2 errors about locale code and email" do
        expect(subject.errors.attribute_names).to match(%i[email locale_code])
      end
    end

    context "international address validations" do
      let(:params) { { "locale_code" => "non_uk", "international_address" => "" } }

      before do
        subject.valid?
      end

      it "returns an error if its empty" do
        expect(subject.errors[:international_address]).to include(
          I18n.t(
            "activemodel.errors.models.contact_details_form.attributes.international_address.blank",
          ),
        )
      end
    end

    context "UK address fields validations" do
      let(:params) do
        {
          "locale_code" => "uk",
          "address_line_two" => "",
          "international_address" => "",
          "address_line_one" => "",
          "town_city" => "",
          "postcode" => "",
        }
      end

      before do
        subject.valid?
      end

      it "returns an error if its empty" do
        ContactDetailsForm::MANDATORY_UK_ADDRESS_FIELDS.each do |field|
          expect(subject.errors[field]).to include(
            I18n.t("activemodel.errors.models.contact_details_form.attributes.#{field}.blank"),
          )
        end
      end

      it "returns no error for address_line_two because it is optional" do
        expect(subject.errors[:address_line_two]).to be_empty
      end
    end
  end

  describe "#stash" do
    let(:trainee) { create(:trainee) }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and contact_details" do
      expect(form_store).to receive(:set).with(trainee.id, :contact_details, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:params) { {} }
    let(:trainee) { create(:trainee) }
    let(:address_line_one) { Faker::Address.street_address }

    before do
      allow(form_store).to receive(:get).and_return({
        "address_line_one" => address_line_one,
        "email" => "test @example.com",
      })
      allow(form_store).to receive(:set).with(trainee.id, :contact_details, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      expect { subject.save! }.to change(trainee, :address_line_one).to(address_line_one)
    end

    it "strips whitespace from emails" do
      expect { subject.save! }.to change(trainee, :email).to("test@example.com")
    end
  end
end
