# frozen_string_literal: true

module NavigationBar
  class ViewPreview < ViewComponent::Preview
    def default
      render NavigationBar::View.new(nil)
    end

    def with_a_user_signed_in
      render NavigationBar::View.new({ first_name: "Ted" })
    end
  end
end
