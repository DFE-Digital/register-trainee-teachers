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
    provider.update!(name: name, accreditation_id: accreditation_id, accredited: true)
  end
end
