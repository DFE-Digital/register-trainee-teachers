# frozen_string_literal: true

module ContactDetails
  class View < GovukComponent::Base
    include SanitizeHelper

    def initialize(data_model:, has_errors: false, system_admin: false)
      @data_model = data_model
      @has_errors = has_errors
      @system_admin = system_admin
    end

    def contact_detail_rows
      [
        address_row,
        email_row,
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors, :system_admin

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def address_row
      is_invalid_address = data_model.locale_code.nil? || (uk_address.blank? && international_address.blank?)

      mappable_field(is_invalid_address ? nil : formatted_address, t(".address"))
    end

    def email_row
      mappable_field(data_model.email.presence, t(".email"))
    end

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

    def formatted_address
      address = (data_model.uk? ? uk_address : international_address)
        .reject(&:blank?)
        .map { |item| html_escape(item) }
        .join(tag.br)

      sanitize(address)
    end

    def mappable_field(field_value, field_label)
      { field_value: field_value, field_label: field_label, action_url: trainee_contact_details_path(trainee) }
    end 
  end
end
