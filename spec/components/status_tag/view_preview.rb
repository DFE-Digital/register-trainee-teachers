# frozen_string_literal: true

module StatusTag
  class ViewPreview < ViewComponent::Preview
    Trainee.states.keys.each do |state|
      if %w[recommended_for_award awarded].include?(state)
        define_method "#{state}_qts" do
          render_tag(:assessment_only, state)
        end
        define_method "#{state}_eyts" do
          render_tag(:early_years_undergrad, state)
        end
      else
        define_method state.to_s do
          render_tag(:assessment_only, state)
        end
      end
    end

  private

    def render_tag(route, state)
      render(StatusTag::View.new(trainee: Trainee.new(training_route: route, state: state)))
    end
  end
end
