require "govuk/components"
module Trainees
  module Confirmation
    module Diversity
      class ViewPreview < ViewComponent::Preview
        def not_disclosed
          render_component(Trainees::Confirmation::Diversity::View.new(trainee: mock_trainee_with_no_disclosure))
        end

        def disclosed_with_no_ethnic_group
          render_component(Trainees::Confirmation::Diversity::View.new(trainee: mock_trainee_with_disclosure_and_no_ethnic_group))
        end

        def disclosed_with_ethnic_group
          render_component(Trainees::Confirmation::Diversity::View.new(trainee: mock_trainee_with_disclosure_and_ethnic_group))
        end

        def disclosed_with_no_disabilities
          render_component(Trainees::Confirmation::Diversity::View.new(trainee: mock_trainee_with_disclosure_and_no_disabilities))
        end

        def disclosed_with_disabilities
          render_component(Trainees::Confirmation::Diversity::View.new(trainee: mock_trainee_with_disclosure_and_disabilities))
        end

      private

        def mock_trainee_with_no_disclosure
          OpenStruct.new({
            id: 1,
            diversity_disclosure: "diversity_not_disclosed",
          })
        end

        def mock_trainee_with_disclosure
          OpenStruct.new({
            id: 1,
            diversity_disclosure: "diversity_disclosed",
          })
        end

        def mock_trainee_with_disclosure_and_ethnic_group
          OpenStruct.new({
            id: 1,
            diversity_disclosure: "diversity_disclosed",
            ethnic_group: "mixed_ethnic_group",
            ethnic_background: "Asian and White",
          })
        end

        def mock_trainee_with_disclosure_and_no_ethnic_group
          OpenStruct.new({
            id: 1,
            diversity_disclosure: "diversity_disclosed",
            ethnic_group: "not_provided_ethnic_group",
          })
        end

        def mock_trainee_with_disclosure_and_no_disabilities
          OpenStruct.new({
            id: 1,
            diversity_disclosure: "diversity_disclosed",
            ethnic_group: "not_provided_ethnic_group",
            not_disabled?: true,
          })
        end

        def mock_trainee_with_disclosure_and_disabilities
          OpenStruct.new({
            id: 1,
            diversity_disclosure: "diversity_disclosed",
            ethnic_group: "not_provided_ethnic_group",
            disabled?: true,
            disabilities: [
              OpenStruct.new(name: "Blind"),
              OpenStruct.new(name: "Deaf"),
            ],
          })
        end
      end
    end
  end
end
