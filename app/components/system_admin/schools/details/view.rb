# frozen_string_literal: true

module SystemAdmin
  module Schools
    module Details
      class View < ViewComponent::Base
        attr_reader :school_entity

        def initialize(school_entity)
          @school_entity = school_entity
        end

        def lead_partner?
          if school_entity.is_a?(School)
            school_entity.lead_school
          else
            school_entity.lead_partner
          end
        end
      end
    end
  end
end
