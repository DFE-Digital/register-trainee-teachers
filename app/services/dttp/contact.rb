# frozen_string_literal: true

module Dttp
  class Contact
    def initialize(contact_data:)
      @contact_data = contact_data
    end

    def dttp_id
      contact_data["contactid"]
    end

    def first_name
      contact_data["firstname"]
    end

    def last_name
      contact_data["lastname"]
    end

    def email_address
      contact_data["emailaddress1"]
    end

    def updated_at
      contact_data["modifiedon"]
    end

  private

    attr_reader :contact_data
  end
end
