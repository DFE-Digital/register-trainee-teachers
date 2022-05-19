# frozen_string_literal: true

module Dqt
  module Params
    class Withdrawal
      WITHDRAWN = "Withdrawn"

      attr_reader :trainee, :params

      def initialize(trainee:)
        @trainee = trainee
        @params = build_params
      end

      def to_json(*_args)
        params.to_json
      end

    private

      def build_params
        {
          "outcome" => WITHDRAWN,
        }
      end
    end
  end
end
