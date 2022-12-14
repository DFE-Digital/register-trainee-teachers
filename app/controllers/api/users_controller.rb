# frozen_string_literal: true

module Api
  class UsersController < Api::ApplicationController
    def index
      return error_response if invalid_query?

      @user_search = UserSearch.call(**args).users

      render(json: { users: @user_search.as_json(only: %i[id first_name last_name email],
                                                 include: { providers: { only: [:name] },
                                                            lead_schools: { only: [:name] } }) })
    end

  private

    def args
      { query: params[:query], limit: params[:limit] }.compact
    end

    def invalid_query?
      params[:query].present? && params[:query].length < UserSearch::MIN_QUERY_LENGTH
    end

    def error_response
      message = I18n.t("api.errors.bad_request", length: SchoolSearch::MIN_QUERY_LENGTH)
      render_json_error(message: message, status: :bad_request)
    end
  end
end
