# frozen_string_literal: true

module TraineeStartStatus
  class View < ApplicationComponent
    def initialize(data_model:, editable: false)
      @data_model = data_model
      @editable = editable
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def start_status_or_date
      return t("components.confirmation.start_status.itt_not_yet_started") if data_model.itt_not_yet_started?

      data_model.trainee_start_date.strftime("%d %B %Y")
    end

  private

    attr_accessor :data_model, :editable
  end
end
