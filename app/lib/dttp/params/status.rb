# frozen_string_literal: true

module Dttp
  module Params
    class Status
      include Mappable

      attr_reader :status

      def initialize(status:)
        @status = status
      end

      def to_json(*_args)
        params.to_json
      end

      def params
        { "dfe_TraineeStatusId@odata.bind" => "/dfe_traineestatuses(#{dttp_status_id(status)})" }
      end
    end
  end
end
