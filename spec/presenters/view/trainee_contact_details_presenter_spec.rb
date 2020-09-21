require "rails_helper"

module View
  RSpec.describe TraineeContactDetailsPresenter do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee) }

    it "returns presented data" do
      expect(subject.call).to eql({
        "Address" => "#{trainee.address_line_one}, #{trainee.address_line_two}, #{trainee.town_city}, #{trainee.county}",
        "Postcode" => trainee.postcode,
        "Phone number" => trainee.phone_number,
        "Email" => trainee.email,
      })
    end
  end
end
