# frozen_string_literal: true

module BulkUpdate
  class BulkUpdatesController < ApplicationController
    before_action { check_for_provider }

    helper_method :bulk_placements_count, :bulk_recommend_count

    def index; end

  private

    def organisation
      @organisation ||= current_user.organisation
    end

    def bulk_placements_count
      @bulk_placements_count ||= current_user.organisation.trainees_without_required_placements.count
    end

    def bulk_recommend_count
      @bulk_recommend_count ||= policy_scope(FindBulkRecommendTrainees.call).count
    end

    def check_for_provider
      redirect_to(root_path) unless organisation.is_a?(Provider)
    end
  end
end
