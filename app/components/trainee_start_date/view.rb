# frozen_string_literal: true

module TraineeStartDate
  class View < GovukComponent::Base
    def initialize(data_model:, editable: false)
      @data_model = data_model
      @editable = editable
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def start_date
      data_model.commencement_date.strftime("%d %B %Y")
    end

  private

    attr_accessor :data_model, :editable
  end
end
