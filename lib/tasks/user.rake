# frozen_string_literal: true

namespace :user do
  desc "Retain HEI and system admin users only"
  task retain_hei_and_system_admin_users_only: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    provider_user_with_active_hei_providers = ProviderUser.with_active_hei_providers
    ProviderUser.where.not(id: provider_user_with_active_hei_providers.ids).delete_all

    user_ids = ProviderUser.with_active_hei_providers.pluck(:user_id) + User.where(system_admin: true).ids
    User.where.not(id: user_ids).update(dfe_sign_in_uid: nil)

    LeadPartnerUser.delete_all
  end
end
