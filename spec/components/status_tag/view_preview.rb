# frozen_string_literal: true

module StatusTag
  class ViewPreview < ViewComponent::Preview
    Trainee.states.keys.each do |state|
      define_method state.to_s do
        render(StatusTag::View.new(trainee: Trainee.new(state: state)))
      end
    end
  end
end
