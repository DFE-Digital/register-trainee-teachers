# frozen_string_literal: true

module Submissions
  class ApiTrnValidator < BaseValidator
    include FundingHelper

    class_attribute :extra_validators, instance_writer: false, default: {}

    class << self
      def missing_data_validator(name, options)
        extra_validators[name] = options
      end
    end

    missing_data_validator :placements, form: "PlacementDetailForm", if: :requires_placements?

    def all_errors
      sections.map do |section|
        validation = validator(section)
        validation.validate
        validation.errors.full_messages
      end.flatten
    end

  private

    def sections
      [
        :personal_details, :contact_details, :diversity,
        *(:degrees if @trainee.requires_degree?),
        :course_details, :training_details,
        *(:schools if trainee.requires_schools?),
        *(:placements if trainee.requires_placements?),
        *(:funding if trainee.requires_funding?),
        *(:iqts_country if trainee.requires_iqts_country?)
      ]
    end
  end
end
