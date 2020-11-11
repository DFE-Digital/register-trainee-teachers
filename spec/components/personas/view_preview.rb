module Persona
  class ViewPreview < ViewComponent::Preview
    def single_profile
      render_component(Personas::View.new(persona: mock_persona))
    end

  private

    def mock_persona
      User.new(id: 1, first_name: "Tom", last_name: "Jones", provider: Provider.new(name: "Provider A"))
    end
  end
end
