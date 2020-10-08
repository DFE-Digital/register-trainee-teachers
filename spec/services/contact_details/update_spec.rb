require "rails_helper"

module ContactDetails
  describe Update do
    describe ".call" do
      let(:trainee) { create(:trainee) }

      context "when international address attribute provided but with uk locale code" do
        let(:attributes) { { locale_code: "uk", international_address: "some international address" } }

        before do
          described_class.call(trainee: trainee, attributes: attributes)
        end

        it "does not save the international address value" do
          expect(trainee.reload.international_address).to be_nil
        end
      end

      context "when uk address values provided but with non uk locale code" do
        let(:attributes) { { locale_code: "non_uk", international_address: "some international address" } }

        before do
          described_class.call(trainee: trainee, attributes: attributes)
          trainee.reload
        end

        it "does not save the uk address values" do
          expect(trainee.locale_code).to eq(attributes[:locale_code])
          expect(trainee.international_address).to eq(attributes[:international_address])
          expect(trainee.address_line_one).to be_nil
          expect(trainee.address_line_two).to be_nil
          expect(trainee.town_city).to be_nil
          expect(trainee.postcode).to be_nil
        end
      end
    end
  end
end
