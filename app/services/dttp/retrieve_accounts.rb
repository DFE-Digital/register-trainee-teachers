# frozen_string_literal: true

module Dttp
  class RetrieveAccounts
    include ServicePattern
    include SyncPattern

  private

    def default_path
      @default_path ||= "/accounts"
    end
  end
end
