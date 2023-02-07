# frozen_string_literal: true

module DqtDataSummary
  class View < GovukComponent::Base
    def initialize(dqt_data:)
      @dqt_data = dqt_data
    end

  private

    attr_reader :trainee, :dqt_data

    def general
      @general ||= summarise(dqt_data.except("earlyYearsStatus", "initialTeacherTraining"))
    end

    def training_instances
      @training_instances ||= dqt_data["initialTeacherTraining"]&.map { |training| summarise(training) }
    end

    def summarise(data)
      summary = []

      data.each do |key, value|
        summary << {
          key: { text: key, classes: "no-wrap govuk-!-width-one-third" },
          value: { text: value.presence || "-" },
        }
      end

      summary
    end
  end
end
