# frozen_string_literal: true

module Dqt
  module Params
    class Award
      PASS = "Pass"

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
          "ittProviderUkprn" => trainee.provider.ukprn,
          "outcome" => PASS,
          "assessmentDate" => trainee.outcome_date.iso8601,
        }
      end
    end
  end
end
