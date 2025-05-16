# frozen_string_literal: true

module TrsDataSummary
  class View < ViewComponent::Base
    HASH_PATTERNS = [
      {
        # Value pattern - used for startDate, endDate, programmeType, result, etc.
        detector: ->(hash) { hash.key?("value") },
        handler: ->(hash) { hash["value"] },
      },
      {
        # Name pattern - used for provider, qualification, etc.
        detector: ->(hash) { hash.key?("name") && hash.keys.size <= 2 },
        handler: ->(hash) { hash["name"] },
      },
      {
        # Description pattern - used for ageRange
        detector: ->(hash) { hash.key?("description") && hash.keys.size == 1 },
        handler: ->(hash) { hash["description"] },
      },
      # Additional patterns can be added here
    ].freeze

    # Special case handlers for specific array types
    ARRAY_HANDLERS = {
      "subjects" => :process_subjects_array,
      # Add other special array handlers here as needed
    }.freeze

    def initialize(trs_data:)
      @trs_data = trs_data
    end

  private

    attr_reader :trs_data

    def general
      @general ||= process_data(
        trs_data.except(
          "initialTeacherTraining",
          "npqQualifications",
          "mandatoryQualifications",
          "sanctions",
          "alerts",
          "previousNames",
        ),
      )
    end

    def training_instances
      @training_instances ||= trs_data["initialTeacherTraining"]&.map { |training| process_data(training) }
    end

    # Response from TRS is nested and complex, this method flattens it into a more readable format
    # see https://preprod.teacher-qualifications-api.education.gov.uk/swagger/index.html?urls.primaryName=v3_Next
    # /v3/persons/{trn} for more details
    def process_data(data, prefix = "")
      return [] if data.nil?

      result = []

      data.each do |key, value|
        formatted_key = prefix.empty? ? key : "#{prefix}.#{key}"

        case value
        when Array
          result.concat(process_array_value(key, value, formatted_key))
        when Hash
          result.concat(process_hash_value(formatted_key, value))
        else
          result << format_row(formatted_key, value)
        end
      end

      result
    end

    def process_array_value(key, array, prefix)
      # Use specialized handler if one exists for this key
      if ARRAY_HANDLERS.key?(key)
        send(ARRAY_HANDLERS[key], array)
      else
        process_generic_array(array, key, prefix)
      end
    end

    def process_subjects_array(subjects_array)
      subjects_array.each_with_index.map do |subject, index|
        if subject.is_a?(Hash) && subject["name"] && subject["code"]
          format_row("subject#{index + 1}", "#{subject['name']} (#{subject['code']})")
        else
          process_hash_value("subject#{index + 1}", subject)
        end
      end.flatten
    end

    def process_generic_array(array, key, _prefix)
      array.each_with_index.map do |item, index|
        item_key = "#{key}[#{index}]"
        if item.is_a?(Hash)
          process_data(item, item_key)
        else
          format_row(item_key, item)
        end
      end.flatten
    end

    def process_hash_value(key, hash)
      return [] unless hash.is_a?(Hash)

      # Try each pattern in order until one matches
      HASH_PATTERNS.each do |pattern|
        if pattern[:detector].call(hash)
          value = pattern[:handler].call(hash)
          return [format_row(key, value)]
        end
      end

      # If no pattern matches, recurse into the hash
      process_data(hash, key)
    end

    def format_row(key, value)
      {
        key: { text: key, classes: "no-wrap govuk-!-width-one-third" },
        value: { text: format_value(value) },
      }
    end

    def format_value(value)
      return "-" if value.blank?

      value.to_s
    end
  end
end
