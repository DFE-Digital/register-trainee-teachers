# frozen_string_literal: true
module Badges
  class ViewPreview < ViewComponent::Preview

    def single_badge
      render(View.new(badge))
    end

    # def multiple_badges
    #   badges.each do |abadge|
    #     render(View.new(abadge))
    #   end 
    # end 
  private

    def badge(state: "draft", state_name: "Draft", state_colour: "grey")
      {
        state_colour: "#{state_colour}",
        css_class: "govuk-grid-column-one-third",
        trainee_state_count: "1", 
        state_name: "#{state_name}",
        filter: "/trainees?state%5B%5D=#{state}"
      }
    end

    # def badges
    #   [ 
    #     badge(state: "trn_received", state_name: "TRN received", state_colour: "blue"),
    #     badge(state: "withdrawn", state_name: "Withdrawn", state_colour: "red")
    #   ]
    # end
  end 
end 