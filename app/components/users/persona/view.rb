module Users
  module Persona
    class View < GovukComponent::Base
      include SanitizeHelper

      attr_accessor :name, :roles, :link_path

      def initialize(name:, roles: [], description:, link_path:)
        @name = name
        @roles = roles
        @description = description
        @link_path = link_path
      end

      def safe_description
        sanitize(@description)
      end
    end
  end
end
