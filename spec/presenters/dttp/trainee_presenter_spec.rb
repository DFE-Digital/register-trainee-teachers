require "rails_helper"

module Dttp
  describe TraineePresenter do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee: trainee) }

    describe "#to_dttp_params" do
      it "returns a hash formatted for a DTTP contact creation" do
        expect(subject.to_dttp_params).to eql({
          "firstname" => trainee.first_names,
          "lastname" => trainee.last_name,
          "contactid" => trainee.dttp_id,
          "address1_line1" => trainee.address_line_one,
          "address1_line2" => trainee.address_line_two,
          "address1_line3" => trainee.town_city,
          "address1_postalcode" => trainee.postcode,
          "birthdate" => trainee.date_of_birth.strftime("%d/%m/%Y"),
          "emailaddress1" => trainee.email,
          "gendercode" => trainee.gender,
          "mobilephone" => trainee.phone_number,
        })
      end
    end
  end
end
