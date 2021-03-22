# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe Contact do
    context "instantiation" do
      let(:contact_data) do
        {
          "contactid" => "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
          "firstname" => "John",
          "lastname" => "Smith",
          "emailaddress1" => "example@example.com",
        }
      end

      it "can be instantiated" do
        expect(described_class.new(contact_data: contact_data)).to be_a Contact
      end
    end

    context "accessors" do
      let(:contact_data) do
        {
          "contactid" => "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
          "firstname" => "John",
          "lastname" => "Smith",
          "emailaddress1" => "example@example.com",
        }
      end

      it "has accessors to abstract over dttp terminology" do
        contact = described_class.new(contact_data: contact_data)
        expect(contact.first_name).to eq "John"
        expect(contact.last_name).to eq "Smith"
        expect(contact.dttp_id).to eq "XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
        expect(contact.email_address).to eq "example@example.com"
      end
    end
  end
end
