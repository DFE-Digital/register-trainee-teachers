# frozen_string_literal: true

module OrganisationSwitcher
  class ViewPreview < ViewComponent::Preview
    def default
      render OrganisationSwitcher::View.new(current_user:)
    end

  private

    def current_user
      @current_user ||= UserWithOrganisationContext.new(
        user: user,
        session: { current_organisation: { id: providers[0].id, type: "Provider" } },
      )
    end

    def user
      @user ||= FactoryBot.create(:user, providers:)
    end

    def providers
      @providers ||= FactoryBot.create_list(:provider, 2)
    end
  end
end
