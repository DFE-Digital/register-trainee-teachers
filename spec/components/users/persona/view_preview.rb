module Users
  module Persona
    class ViewPreview < ViewComponent::Preview
      def single_profile
        render_component(Users::Persona::View.new(
                           name: "Tom Jones",
                           roles: ["Admin", "Second Role"],
                           description: '<p class="govuk-body">Managed trainees for Provider A</p>',
                           link_path: "",
                         ))
      end
    end
  end
end
