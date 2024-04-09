# frozen_string_literal: true

module Api
  class FindDuplicateTrainees
    include ServicePattern
    include FindDuplicatesBase

    def initialize(current_provider:, trainee_attributes:, serializer:)
      @current_provider   = current_provider
      @trainee_attributes = trainee_attributes
      @serializer         = serializer
    end

    def call
      potential_duplicates(current_provider)
        .select { |trainee| confirmed_duplicate?(trainee) }
        .map { |trainee| serializer.new(trainee).as_hash }
    end

  private

    attr_reader :current_provider, :trainee_attributes, :serializer

    def date_of_birth
      trainee_attributes.date_of_birth
    end

    def last_name
      trainee_attributes.last_name
    end

    def first_names
      trainee_attributes.first_names
    end

    def email
      trainee_attributes.email
    end

    def training_route
      trainee_attributes.training_route
    end

    def recruitment_cycle_year
      if trainee_attributes.itt_start_date.is_a?(String)
        trainee_attributes.itt_start_date = Date.parse(trainee_attributes.itt_start_date)
      end

      trainee_attributes.itt_start_date&.year
    end
  end
end
