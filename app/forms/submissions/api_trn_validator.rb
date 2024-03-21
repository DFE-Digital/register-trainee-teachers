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
      @all_errors ||= sections.each_with_object({}) do |section, errors_hash|
        next unless validator_keys.include?(section)

        validation = validator(section)
        next if validation.validate

        errors_hash[section] = validation.errors.messages
      end
    end

    def errors_count
      @errors_count ||= all_errors.values.sum { |section| section.values.sum(&:length) }
    end

  private

    def sections
      [
        :personal_details, :contact_details, :diversity,
        *(:degrees if @trainee.requires_degree?),
        :course_details, # `:training_details` seems unnecessary as it only details trainee_id which according to DD is not needed
        *(:schools if trainee.requires_schools?),
        *(:placements if trainee.requires_placements?),
        *(:funding if trainee.requires_funding?),
        *(:iqts_country if trainee.requires_iqts_country?)
      ]
    end
  end
end
