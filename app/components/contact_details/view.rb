# frozen_string_literal: true

module ContactDetails
  class View < GovukComponent::Base
    include SanitizeHelper

    def initialize(data_model:, has_errors: false, editable: false)
      @data_model = data_model
      @has_errors = has_errors
      @editable = editable
    end

    def contact_detail_rows
      [email_row].compact
    end

  private

    attr_accessor :data_model, :has_errors, :editable

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def email_row
      mappable_field(data_model.email.presence, t(".email"))
    end

    def mappable_field(field_value, field_label)
      { field_value: field_value, field_label: field_label, action_url: edit_trainee_contact_details_path(trainee) }
    end
  end
end
