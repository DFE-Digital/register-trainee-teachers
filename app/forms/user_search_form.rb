# frozen_string_literal: true

class UserSearchForm
  include ActiveModel::Model
  include ApplicationHelper
  attr_accessor :user, :user_raw, :users
  def initialize(scope: :all)
    @users = User.send(scope).includes(:providers, :lead_schools).uniq
  end

  def search_options
    to_enhanced_options(search_values) do |search_option|
      [
        search_option[:name],
        search_option[:id],
        { "data-synonyms" => Array(search_option[:synonyms]).join("|") },
        { "data-hint" => "<span class='autocomplete__option--hint'> #{search_option_preview(search_option)}</span>" },
      ]
    end
  end

private

  def search_option_preview(search_option)
    return unless search_option

    search_option[:synonyms].join("<br />")
  end

  def search_values
    @search_values ||= users.map do |u|
      {
        id: u.id,
        name: u.name,
        synonyms: [u.email, *u.provider_names, *u.lead_school_names],
      }
    end
  end
end
