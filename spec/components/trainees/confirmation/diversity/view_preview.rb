# frozen_string_literal: true

require "govuk/components"
module Trainees
  module Confirmation
    module Diversity
      class ViewPreview < ViewComponent::Preview
        def not_disclosed
          render(Trainees::Confirmation::Diversity::View.new(data_model: mock_trainee_with_no_disclosure))
        end

        def disclosed_with_no_ethnic_group
          render(Trainees::Confirmation::Diversity::View.new(data_model: mock_trainee_with_disclosure_and_no_ethnic_group))
        end

        def disclosed_with_ethnic_group
          render(Trainees::Confirmation::Diversity::View.new(data_model: mock_trainee_with_disclosure_and_ethnic_group))
        end

        def disclosed_with_no_disabilities
          render(Trainees::Confirmation::Diversity::View.new(data_model: mock_trainee_with_disclosure_and_no_disabilities))
        end

        def disclosed_with_disabilities
          render(Trainees::Confirmation::Diversity::View.new(data_model: mock_trainee_with_disclosure_and_disabilities))
        end

      private

        def mock_trainee_with_no_disclosure
          Trainee.new({
            id: 1,
            diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed],
          })
        end

        def mock_trainee_with_disclosure
          Trainee.new({
            id: 1,
            diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
          })
        end

        def mock_trainee_with_disclosure_and_ethnic_group
          Trainee.new({
            id: 1,
            diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
            ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:mixed],
            ethnic_background: "Asian and White",
          })
        end

        def mock_trainee_with_disclosure_and_no_ethnic_group
          Trainee.new({
            id: 1,
            diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
            ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
          })
        end

        def mock_trainee_with_disclosure_and_no_disabilities
          Trainee.new({
            id: 1,
            diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
            ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
          })
        end

        def mock_trainee_with_disclosure_and_disabilities
          Trainee.new({
            id: 1,
            diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
            ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
            disabilities: [
              Disability.new(name: "Blind"),
              Disability.new(name: "Deaf"),
            ],
          })
        end
      end
    end
  end
end
