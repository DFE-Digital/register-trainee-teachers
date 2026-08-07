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
  DEFAULT_LIMIT = Settings.pagination.records_per_page

  def initialize(query: nil, limit: DEFAULT_LIMIT, scope: User.all)
    @raw_query = query&.strip
    @limit = limit
    @scope = scope
  end

  def call
    Result.new(users: specified_users, limit: limit)
  end

  def specified_users
    users = scope
    users = filter_users(users) if raw_query.present?
    users = users.limit(limit) if limit
    users
  end

private

  attr_reader :raw_query, :limit, :scope

  def filter_users(users)
    if email_query?
      users.where("email LIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(raw_query.downcase)}%")
    else
      users.search(normalised_query)
    end
  end

  def email_query?
    raw_query.include?("@")
  end

  def normalised_query
    ReplaceAbbreviation.call(string: StripPunctuation.call(string: raw_query))
  end
end
