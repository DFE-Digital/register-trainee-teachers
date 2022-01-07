# frozen_string_literal: true

module Personas
  class ViewPreview < ViewComponent::Preview
    def single_profile
      render(Personas::View.new(persona: mock_persona))
    end

  private

    def mock_persona
      provider = FactoryBot.create(:provider, name: "Provider A")
      FactoryBot.create(:user, first_name: "Tom", last_name: "Jones", providers: [provider])
    end
  end
end
