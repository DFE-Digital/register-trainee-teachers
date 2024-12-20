# frozen_string_literal: true

require "bullet" unless Rails.env.local?

using Bullet::Ext::Object

# rubocop:disable Rails/Delegate
module Bullet
  module SimpleDelegatorHelpers
    def bullet_primary_key_value
      __getobj__.bullet_primary_key_value
    end

    def bullet_key
      __getobj__.bullet_key
    end
  end
end
# rubocop:enable Rails/Delegate
