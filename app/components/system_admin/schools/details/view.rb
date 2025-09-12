# frozen_string_literal: true

module SystemAdmin
  module Schools
    module Details
      class View < ApplicationComponent
        attr_reader :school_entity
        delegate :lead_partner?, to: :school_entity

        def initialize(school_entity)
          @school_entity = school_entity
        end
      end
    end
  end
end
