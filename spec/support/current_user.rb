# frozen_string_literal: true

def build_current_user(user: create(:user), session: {})
  UserWithOrganisationContext.new(user:, session:)
end
