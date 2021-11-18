# frozen_string_literal: true

module DeferralDetails
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model))
    end

    def deferred_before_starting
      render(View.new(OpenStruct.new(trainee: trainee, date: nil)))
    end

  private

    def trainee
      @trainee ||= Trainee.new(id: 1, defer_date: Time.zone.yesterday)
    end

    def data_model
      OpenStruct.new(trainee: trainee, date: trainee.defer_date)
    end
  end
end
