# frozen_string_literal: true

module Sluggable
  extend ActiveSupport::Concern

  SLUG_LENGTH = 24

  included do
    attr_readonly :slug
    has_secure_token :slug

    after_initialize :generate_slug, if: -> { slug.blank? }

    validates :slug, presence: true
  end

  def to_param
    slug
  end

  def generate_slug
    self.slug = SecureRandom.base58(SLUG_LENGTH)
  end

  class_methods do
    def from_param(param)
      find_by!(slug: param)
    end
  end
end
