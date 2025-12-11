# frozen_string_literal: true

class CopyProvidersToTrainingPartnersService
  include ServicePattern

  RECORD_TYPES = [
    TrainingPartner::HEI,
    TrainingPartner::SCITT,
  ].freeze

  attr_reader :provider_ids, :record_type

  def initialize(provider_ids:, record_type:)
    @provider_ids = provider_ids
    @record_type  = record_type
  end

  def call
    raise("'#{record_type}' is not a valid record_type, should be one of #{RECORD_TYPES}") unless record_type.to_s.in?(RECORD_TYPES)

    Provider.where(id: provider_ids).find_each do |provider|
      ActiveRecord::Base.transaction do
        training_partner = TrainingPartner.find_or_create_by!(ukprn: provider.ukprn, provider_id: provider.id) do |tp|
          tp.name        = provider.name
          tp.record_type = record_type
        end

        provider.update!(accredited: false)

        # Ensure training_partner_users are up-to-date
        provider.users.each do |user|
          TrainingPartnerUser.find_or_create_by!(training_partner:, user:)
        end

        # Remove any TrainingPartnerUser records that no longer correspond to the provider's users
        TrainingPartnerUser.where(training_partner:).where.not(user_id: provider.user_ids).find_each(&:destroy!)
      end
    end
  end
end
