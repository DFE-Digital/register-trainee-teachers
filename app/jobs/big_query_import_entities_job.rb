# frozen_string_literal: true

class BigQueryImportEntitiesJob < ApplicationJob
  queue_as :dfe_analytics

  def perform
    DfE::Analytics.entities_for_analytics.each do |entity_name|
      DfE::Analytics::LoadEntities.new(entity_name:).run
    end
  end
end
