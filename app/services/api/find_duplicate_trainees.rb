# frozen_string_literal: true

module Api
  class FindDuplicateTrainees
    include ServicePattern
    include FindDuplicatesBase

    def initialize(current_provider:, trainee_attributes:, serializer_klass:)
      @current_provider   = current_provider
      @trainee_attributes = trainee_attributes
      @serializer_klass   = serializer_klass
    end

    def call
      potential_duplicates(current_provider)
        .select { |trainee| confirmed_duplicate?(trainee) }
        .map { |trainee| serializer_klass.new(trainee).as_hash }
    end

  private

    attr_reader :current_provider, :trainee_attributes, :serializer_klass

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
      AcademicCycle.for_date(trainee_attributes.itt_start_date)&.start_year
    end
  end
end
