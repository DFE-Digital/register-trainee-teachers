# frozen_string_literal: true

require "govuk/components"

module TraineeName
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(
               Trainee.new(first_names: "Joe", middle_names: "Smith", last_name: "Blogs"),
             ))
    end

    def draft_with_no_name
      render(View.new(
               Trainee.new(state: "draft", first_names: nil, middle_names: nil, last_name: nil),
             ))
    end

    def non_draft_with_no_name
      render(View.new(
               Trainee.new(state: "submitted_for_trn", first_names: nil, middle_names: nil, last_name: nil),
             ))
    end
  end
end
