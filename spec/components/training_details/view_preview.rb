# frozen_string_literal: true

require "govuk/components"

module TrainingDetails
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model: Trainee.new(shared_attributes)))
    end

    def with_region
      render(View.new(data_model: hpitt_trainee))
    end

  private

    def hpitt_trainee
      Trainee.new(
        shared_attributes.merge(
          region: Dttp::CodeSets::Regions::MAPPING.keys.sample,
          provider: Provider.new(code: TEACH_FIRST_PROVIDER_CODE),
        ),
      )
    end

    def shared_attributes
      date = Date.new(2020, 0o1, 28)

      {
        id: 1,
        trainee_id: "#{date.year}/#{date.year + 1}-1",
      }
    end
  end
end
