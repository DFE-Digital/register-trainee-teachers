require "rails_helper"

module ContactDetails
  module Utilities
    describe AddressAttributes do
      describe "#attributes" do
        subject { described_class.new(attributes) }

        context "when international address attribute provided but with uk locale code" do
          let(:attributes) { { locale_code: "uk", international_address: "some international address" } }

          it "does not set international address value" do
            expect(subject.attributes[:international_address]).to be_nil
          end
        end

        context "when uk address values provided but with non uk locale code" do
          let(:attributes) do
            {
              locale_code: "non_uk",
              international_address: Faker::Address.street_name,
              address_line_one: Faker::Address.street_name,
              address_line_two: Faker::Address.street_name,
              town_city: Faker::Address.city_suffix,
              postcode: Faker::Address.postcode,
            }
          end

          it "does not set the uk address values" do
            expect(subject.attributes[:locale_code]).to eq(attributes[:locale_code])
            expect(subject.attributes[:international_address]).to eq(attributes[:international_address])
            expect(subject.attributes[:address_line_one]).to be_nil
            expect(subject.attributes[:address_line_two]).to be_nil
            expect(subject.attributes[:town_city]).to be_nil
            expect(subject.attributes[:postcode]).to be_nil
          end
        end
      end
    end
  end
end
