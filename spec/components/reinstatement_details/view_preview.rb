# frozen_string_literal: true

module ReinstatementDetails
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(reinstatement_form:, itt_end_date_form:))
    end

  private

    def trainee
      @trainee ||= OpenStruct.new(id: 1, reinstate_date: Faker::Date.in_date_period)
    end

    def reinstatement_form
      OpenStruct.new(trainee: trainee, date: trainee.reinstate_date)
    end

    def itt_end_date_form
      OpenStruct.new(trainee: trainee, itt_end_date: 1.year.since(trainee.reinstate_date))
    end
  end
end
