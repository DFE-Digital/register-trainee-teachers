# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                    :bigint           not null, primary key
#  dfe_sign_in_uid       :string
#  discarded_at          :datetime
#  email                 :string           not null
#  first_name            :string           not null
#  last_name             :string           not null
#  last_signed_in_at     :datetime
#  otp_secret            :string
#  read_only             :boolean          default(FALSE)
#  system_admin          :boolean          default(FALSE)
#  welcome_email_sent_at :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  dttp_id               :uuid
#
# Indexes
#
#  index_unique_active_dttp_users  (dttp_id) UNIQUE WHERE (discarded_at IS NULL)
#  index_unique_active_users       (email) UNIQUE WHERE (discarded_at IS NULL)
#  index_users_on_dfe_sign_in_uid  (dfe_sign_in_uid) UNIQUE
#  index_users_on_discarded_at     (discarded_at)
#
class Persona < User
  def self.notable_user_ids
    popular_providers = Provider.kept
      .joins(:trainees)
      .group(:id)
      .order("COUNT(trainees.id) DESC")
      .limit(10)

    user_ids = popular_providers
      .flat_map { |provider| provider.users.kept.sample.id }

    user_ids += PERSONA_IDS

    user_ids
  end

  default_scope { where(email: PERSONA_EMAILS).or(where(id: notable_user_ids)) }
end
