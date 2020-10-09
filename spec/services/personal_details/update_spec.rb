require "rails_helper"

module PersonalDetails
  describe Update do
    describe ".call" do
      let(:trainee) { create(:trainee, nationalities: [create(:nationality)] ) }
      let(:service) { described_class.new(trainee: trainee, attributes: attributes) }

      context "when personal details are valid" do
        let(:attributes) { { first_names: "Jon" } }

        before do
          service.call
          trainee.reload
        end

        it "updates the trainee's personal details" do
          expect(trainee.first_names).to eq(attributes[:first_names])
        end

        it "is successful" do
          expect(service).to be_successful
        end
      end

      context "when personal details are invalid" do
        let(:attributes) { { first_names: nil } }

        before do
          service.call
          trainee.reload
        end

        it "does not update the trainee's personal details" do
          expect(trainee.first_names).to_not eq(attributes[:first_names])
        end

        it "is unsuccessful" do
          expect(service).to_not be_successful
        end
      end
    end
  end
end
