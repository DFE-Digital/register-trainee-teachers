# frozen_string_literal: true

class UserSearch
  include ServicePattern

  class Result
    attr_reader :users, :limit

    def initialize(users:, limit:)
      @users = users
      @limit = limit
    end
  end

  MIN_QUERY_LENGTH = 2
  DEFAULT_LIMIT = 15

  def initialize(query: nil, limit: DEFAULT_LIMIT, scope: User.all)
    @query = ReplaceAbbreviation.call(string: StripPunctuation.call(string: query))
    @limit = limit
    @scope = scope
  end

  def call
    Result.new(users: specified_users, limit: limit)
  end

  def specified_users
    users = scope
    users = users.search(query) if query
    users = users.limit(limit) if limit
    users
  end

private

  attr_reader :query, :limit, :scope
end
