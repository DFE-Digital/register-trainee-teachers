# frozen_string_literal: true

module Badges
  class ViewPreview < ViewComponent::Preview
    include FactoryBot::Syntax::Methods

    def with_generic_award_states
      counts = state_counts.merge(
        awarded: random_count,
        recommended_for_award: random_count,
      )
      render(Badges::View.new(counts))
    end

    def with_eyts_states
      counts = state_counts.merge(
        eyts_recommended: random_count,
        eyts_received: random_count,
      )
      render(Badges::View.new(counts))
    end

    def with_qts_states
      counts = state_counts.merge(
        qts_recommended: random_count,
        qts_received: random_count,
      )
      render(Badges::View.new(counts))
    end

  private

    def random_count
      Array(1..100).sample
    end

    def state_counts
      {
        submitted_for_trn: random_count,
        trn_received: random_count,
        deferred: random_count,
        withdrawn: random_count,
      }.with_indifferent_access
    end
  end
end
