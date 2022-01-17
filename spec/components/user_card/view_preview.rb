# frozen_string_literal: true

require "govuk/components"
module UserCard
  class ViewPreview < ViewComponent::Preview
    def single_card
      render(UserCard::View.new(user: mock_user))
    end

    def multiple_cards
      render(UserCard::View.with_collection(mock_users))
    end

  private

    def mock_user
      provider = FactoryBot.create(
        :provider,
        name: "Provider A",
        dttp_id: SecureRandom.uuid,
      )

      FactoryBot.create(
        :user,
        first_name: "Luke",
        last_name: "Skywalker",
        email: "luke@email.com",
        created_at: Time.zone.now,
        dttp_id: SecureRandom.uuid,
        providers: [provider],
      )
    end

    def mock_users
      [
        mock_user,
        mock_user,
      ]
    end
  end
end
