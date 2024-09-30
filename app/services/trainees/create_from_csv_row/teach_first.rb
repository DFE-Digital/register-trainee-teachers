# frozen_string_literal: true

module Trainees
  module CreateFromCsvRow
    class TeachFirst < Base
      def initialize(csv_row:)
        provider = Provider.find_by!(code: Provider::TEACH_FIRST_PROVIDER_CODE)
        super(csv_row:, provider:)
      end

    private

      def after_actions
        trainee.course_uuid = course_uuid
        super
      end
    end
  end
end
