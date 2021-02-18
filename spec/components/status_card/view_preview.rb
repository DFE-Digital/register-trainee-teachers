# frozen_string_literal: true

module StatusCard
  class ViewPreview < ViewComponent::Preview
    def single_card
      render inline: "<div class=\"govuk-grid-row govuk-!-margin-bottom-6\"><%= render(StatusCard::View.new(card))%></div>", locals: { card: card }
    end

    def multiple_cards
      current_user = User.new(first_name: "Darth", last_name: "Vader", email: "darth@email.com", system_admin: true)
      render partial: "pages/badges.html.erb", locals: { current_user: current_user }
    end

  private

    def card(state: "draft", state_name: "Draft", status_colour: "grey")
      {
        status_colour: status_colour.to_s,
        count: "1",
        state_name: state_name.to_s,
        target: "/trainees?state%5B%5D=#{state}",
      }
    end
  end
end
