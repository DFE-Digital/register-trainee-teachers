# frozen_string_literal: true

module TraineeStartDate
  class View < GovukComponent::Base
    attr_accessor :data_model

    def initialize(data_model:)
      @data_model = data_model
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def start_date
      data_model.commencement_date.strftime("%d %B %Y")
    end
  end
end
