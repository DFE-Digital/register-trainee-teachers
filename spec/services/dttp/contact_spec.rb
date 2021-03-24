# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe Contact do
    let(:contact_data) do
      {
        "contactid" => "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "firstname" => "John",
        "lastname" => "Smith",
        "emailaddress1" => "example@example.com",
      }
    end

    subject { described_class.new(contact_data: contact_data) }

    describe "methods" do
      it "has accessors to abstract over dttp terminology" do
        expect(subject.first_name).to eq "John"
        expect(subject.last_name).to eq "Smith"
        expect(subject.dttp_id).to eq "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
        expect(subject.email_address).to eq "example@example.com"
      end
    end
  end
end
