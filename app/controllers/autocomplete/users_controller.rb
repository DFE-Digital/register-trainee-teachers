# frozen_string_literal: true

module Autocomplete
  class UsersController < Autocomplete::BaseController
    before_action :authorize_system_admin!

    def index
      return error_response if invalid_query?

      @user_search = filtered_users
      render(json: {
        users: @user_search.as_json(
          only: %i[id first_name last_name email],
          include: {
            providers: { only: [:name] },
            training_partners: { only: [:name] },
          },
        ),
      })
    end

  private

    def authorize_system_admin!
      return if policy(User).index?

      render_json_error(message: "Forbidden", status: :forbidden)
    end

    def args
      { query: params[:query], limit: params[:limit] }.compact
    end

    def invalid_query?
      params[:query].present? && params.expect(:query).length < UserSearch::MIN_QUERY_LENGTH
    end

    def error_response
      message = I18n.t("api.errors.bad_request", length: SchoolSearch::MIN_QUERY_LENGTH)
      render_json_error(message: message, status: :bad_request)
    end

    def filtered_users
      UserSearch.call(**args, scope: User.kept.includes(%i[providers training_partners])).users
    end
  end
end
