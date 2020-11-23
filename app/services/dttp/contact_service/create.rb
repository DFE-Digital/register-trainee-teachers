# frozen_string_literal: true

module Dttp
  module ContactService
    class Create < Base
      def call
        response = Client.post("/contacts", { body: trainee.contact_params.to_json, headers: headers })
        trainee.update!(dttp_id: parse_contactid(response))
      end
    end
  end
end
