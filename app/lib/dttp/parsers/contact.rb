# frozen_string_literal: true

module Dttp
  module Parsers
    class Contact
      class << self
        def to_user_attributes(contacts:)
          contacts.map do |contact|
            {
              first_name: contact["firstname"],
              last_name: contact["lastname"],
              email: contact["emailaddress1"],
              dttp_id: contact["contactid"],
              provider_dttp_id: contact["_parentcustomerid_value"],
            }
          end
        end

        def to_trainee_attributes(contacts:)
          contacts.map do |contact|
            {
              dttp_id: contact["contactid"],
              provider_dttp_id: contact["_parentcustomerid_value"],
              response: contact,
            }
          end
        end
      end
    end
  end
end
