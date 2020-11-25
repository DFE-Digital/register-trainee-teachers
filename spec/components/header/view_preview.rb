# frozen_string_literal: true

module Header
  class ViewPreview < ViewComponent::Preview
    def with_custom_service_name
      render_component(Header::View.new("Hello"))
    end

    def with_our_service_name
      render_component(Header::View.new(I18n.t("service_name")))
    end

    def with_a_user_signed_in
      render_component(Header::View.new(I18n.t("service_name"), { first_name: "Ted" }))
    end

  private

    def setup_form
      '<div class="govuk-form-group">
        <label class="govuk-label" for="select-1">
          Select a country
        </label>
        <select class="govuk-select" id="select-1" name="select-1">
          <option value="">Select a country</option>
          <option value="fr">France</option>
          <option value="de">Germany</option>
          <option value="gb">United Kingdom</option>
        </select>
      </div>'
    end
  end
end
