# frozen_string_literal: true

module Header
  class ViewPreview < ViewComponent::Preview
    def with_custom_service_name
      render(Header::View.new("Hello"))
    end

    def with_our_service_name
      render(Header::View.new(I18n.t("service_name")))
    end

    def with_a_user_signed_in
      render(Header::View.new(I18n.t("service_name"), User.new(id: 1, system_admin: true)))
    end
  end
end
