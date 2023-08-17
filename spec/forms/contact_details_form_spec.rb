# frozen_string_literal: true

require "rails_helper"

describe ContactDetailsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }

    context "empty form data" do
      let(:params) do
        {
          "email" => "",
        }
      end

      before do
        subject.valid?
      end

      it "returns 1 error about email" do
        expect(subject.errors.attribute_names).to match(%i[email])
      end
    end

    # context "international address validations" do
    #   let(:params) { { "locale_code" => "non_uk", "international_address" => "" } }

    #   before do
    #     subject.valid?
    #   end

    #   it "returns an error if its empty" do
    #     expect(subject.errors[:international_address]).to include(
    #       I18n.t(
    #         "activemodel.errors.models.contact_details_form.attributes.international_address.blank",
    #       ),
    #     )
    #   end
    # end

    # context "UK address fields validations" do
    #   let(:params) do
    #     {
    #       "locale_code" => "uk",
    #       "address_line_two" => "",
    #       "international_address" => "",
    #       "address_line_one" => "",
    #       "town_city" => "",
    #       "postcode" => "",
    #     }
    #   end

    #   before do
    #     subject.valid?
    #   end

    #   it "returns an error if its empty" do
    #     ContactDetailsForm::MANDATORY_UK_ADDRESS_FIELDS.each do |field|
    #       expect(subject.errors[field]).to include(
    #         I18n.t("activemodel.errors.models.contact_details_form.attributes.#{field}.blank"),
    #       )
    #     end
    #   end

    #   it "returns no error for address_line_two because it is optional" do
    #     expect(subject.errors[:address_line_two]).to be_empty
    #   end
    # end

    # context "HESA trainee record" do
    #   let(:trainee) { build(:trainee, locale_code: nil, hesa_id: "XXX") }
    #   let(:params) do
    #     {
    #       "locale_code" => "uk",
    #       "address_line_one" => "test",
    #       "address_line_two" => "test",
    #       "international_address" => "test",
    #       "town_city" => "test",
    #       "postcode" => "E1 5DJ",
    #     }
    #   end

    #   before do
    #     subject.valid?
    #   end

    #   it "does not show address validation errors" do
    #     expect(subject.errors[:international_address]).to be_empty
    #     expect(subject.errors[:address_line_two]).to be_empty
    #     ContactDetailsForm::MANDATORY_UK_ADDRESS_FIELDS.each do |field|
    #       expect(subject.errors[field]).to be_empty
    #     end
    #   end

    #   it "nullifies all the address fields" do
    #     subject.send(:nullify_unused_address_fields!)
    #     params.each do |k, _v|
    #       expect(subject.fields[k.to_sym]).to be_nil
    #     end
    #   end
    # end
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
    # let(:address_line_one) { Faker::Address.street_address }

    before do
      allow(form_store).to receive(:get).and_return({
        # "address_line_one" => address_line_one,
        "email" => "test @example.com",
        # "postcode" => " SW1P 3BT ",
      })
      allow(form_store).to receive(:set).with(trainee.id, :contact_details, nil)
    end

    # it "takes any data from the form store and saves it to the database" do
    #   expect { subject.save! }.to change(trainee, :address_line_one).to(address_line_one)
    # end

    it "strips all whitespace from emails" do
      expect { subject.save! }.to change(trainee, :email).to("test@example.com")
    end

    # it "strips leading and trailing whitespace from postcodes" do
    #   expect { subject.save! }.to change(trainee, :postcode).to("SW1P 3BT")
    # end
  end
end
