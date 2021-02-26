# frozen_string_literal: true

module StatusCard
  class ViewPreview < ViewComponent::Preview
    def single_card
      render(StatusCard::View.new(card))
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
