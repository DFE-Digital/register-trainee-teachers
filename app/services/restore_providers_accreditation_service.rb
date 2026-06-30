# frozen_string_literal: true

class RestoreProvidersAccreditationService
  include ServicePattern

  attr_reader :provider, :name, :accreditation_id

  def initialize(provider:, name:, accreditation_id:)
    @provider = provider
    @name = name
    @accreditation_id = accreditation_id
  end

  def call
    ActiveRecord::Base.transaction do
      provider.update!(name: name, accreditation_id: accreditation_id, accredited: true)
      TrainingPartner.kept.find_by(provider_id: provider.id)&.discard
    end
  end
end
