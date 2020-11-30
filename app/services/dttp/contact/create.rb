# frozen_string_literal: true

module Dttp
  module Contact
    class Create
      class << self
        def call(**args)
          new(**args).call
        end
      end

      private_class_method :new

      attr_reader :trainee

      def initialize(trainee:)
        @trainee = trainee
      end

      def call
        response = Client.post("/contacts", body: trainee.contact_params.to_json)
        trainee.update!(dttp_id: OdataParser.entity_id(trainee.id, response))
      end
    end
  end
end
