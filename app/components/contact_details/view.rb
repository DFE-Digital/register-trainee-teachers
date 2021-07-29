# frozen_string_literal: true

module ContactDetails
  class View < GovukComponent::Base
    include SanitizeHelper

    attr_accessor :data_model, :error

    def initialize(data_model:, error: false)
      @data_model = data_model
      @not_provided_copy = I18n.t("components.confirmation.not_provided")
      @error = error
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def address
      return @not_provided_copy if data_model.locale_code.nil? || (uk_address.blank? && international_address.blank?)

      address = (data_model.uk? ? uk_address : international_address).reject(&:blank?)
                                                                      .map { |item| html_escape(item) }
                                                                      .join(tag.br)

      sanitize(address)
    end

    def email
      return @not_provided_copy if data_model.email.blank?

      data_model.email
    end

  private

    def uk_address
      [
        data_model.address_line_one,
        data_model.address_line_two,
        data_model.town_city,
        data_model.postcode,
      ]
    end

    def international_address
      data_model.international_address.split(/\r\n+/)
    end
  end
end
