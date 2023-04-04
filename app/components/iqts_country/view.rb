# frozen_string_literal: true

module IqtsCountry
  class View < ComponentBase
    include SummaryHelper

    def initialize(data_model:, has_errors: false, editable: false)
      @data_model = data_model
      @has_errors = has_errors
      @editable = editable
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def iqts_country_row
      [
        MappableFieldRow.new(
          field_value: data_model.iqts_country,
          field_label: t(".iqts_country"),
          text: t("components.confirmation.missing"),
          action_url: edit_trainee_iqts_country_path(trainee),
          has_errors: has_errors,
          editable: editable,
        ).to_h,
      ]
    end

  private

    attr_accessor :data_model, :has_errors, :editable
  end
end
