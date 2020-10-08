module ContactDetails
  class Update
    attr_reader :trainee, :attributes

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def initialize(trainee:, attributes:)
      @trainee = trainee
      @attributes = attributes
    end

    def call
      trainee.update!(normalised_address_attributes)
    end

  private

    def normalised_address_attributes
      uk_locale? ? attributes.merge(reset_non_uk_attributes) : attributes.merge(reset_uk_attributes)
    end

    def uk_locale?
      attributes[:locale_code] == "uk"
    end

    def reset_uk_attributes
      { address_line_one: nil, address_line_two: nil, town_city: nil, postcode: nil }
    end

    def reset_non_uk_attributes
      { international_address: nil }
    end
  end
end
