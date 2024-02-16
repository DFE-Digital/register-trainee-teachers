# frozen_string_literal: true

module Api
  class FindDuplicateTrainees
    include ServicePattern
    include FindDuplicatesBase

    attr_accessor :provider, :attributes

    def initialize(provider:, attributes:)
      @provider = provider
      @attributes = attributes
    end

    def call
      potential_duplicates.select { |trainee| confirmed_duplicate?(trainee) }
    end

  private

    def date_of_birth
      attributes.date_of_birth
    end

    def last_name
      attributes.last_name
    end

    def first_names
      attributes.first_names
    end

    def email
      attributes.email
    end

    def training_route
      attributes.training_route
    end

    def recruitment_cycle_year
      if attributes.itt_start_date.is_a?(String)
        attributes.itt_start_date = Date.parse(attributes.itt_start_date)
      end

      attributes.itt_start_date&.year
    end
  end
end
