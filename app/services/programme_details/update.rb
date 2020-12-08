# frozen_string_literal: true

module ProgrammeDetails
  class Update
    include ServicePattern

    attr_reader :trainee, :programme_detail, :successful

    alias_method :successful?, :successful

    def initialize(trainee:, attributes: {})
      @trainee = trainee

      @programme_detail = ProgrammeDetail.new(trainee)
      @programme_detail.assign_attributes(attributes)
    end

    def call
      @successful = programme_detail.valid? && trainee.save!

      self
    end
  end
end
