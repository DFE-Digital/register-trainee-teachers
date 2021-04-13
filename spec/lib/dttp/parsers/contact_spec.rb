# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Parsers
    describe Contact do
      describe ".to_user_attributes" do
        let(:contact) { ApiStubs::Dttp::Contact.attributes }

        let(:expected_attributes) do
          {
            first_name: contact["firstname"],
            last_name: contact["lastname"],
            email: contact["emailaddress1"],
            dttp_id: contact["contactid"],
            provider_dttp_id: contact["_parentcustomerid_value"],
          }
        end

        subject { described_class.to_user_attributes(contacts: [contact]) }

        it "returns an array of Dttp::User attributes" do
          expect(subject).to eq([expected_attributes])
        end
      end
    end
  end
end
