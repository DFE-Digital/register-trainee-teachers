# frozen_string_literal: true

module ProviderCard
  class ViewPreview < ViewComponent::Preview
    def single_card
      render(ProviderCard::View.new(provider: mock_provider(id: 1, name: "Provider A")))
    end

    def multiple_cards
      render(ProviderCard::View.with_collection(mock_multiple_providers))
    end

  private

    def mock_provider(id:, name:, user_count: 0)
      provider = Provider.new(id: id, name: name, dttp_id: SecureRandom.uuid)

      user_count.times do |i|
        provider.users.new(
          id: i,
          first_name: "Jenny",
          last_name: "Bloggs",
          email: "test@example.com",
        )
      end

      provider
    end

    def mock_multiple_providers
      [
        mock_provider(id: 1, name: "Provider A", user_count: 1),
        mock_provider(id: 2, name: "Provider B", user_count: 2),
        mock_provider(id: 3, name: "Provider C"),
      ]
    end
  end
end
