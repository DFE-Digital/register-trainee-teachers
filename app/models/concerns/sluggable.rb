# frozen_string_literal: true

module Sluggable
  extend ActiveSupport::Concern

  included do
    has_secure_token :slug
  end

  def to_param
    slug
  end

  class_methods do
    def from_param(param)
      find_by!(slug: param)
    end
  end
end
