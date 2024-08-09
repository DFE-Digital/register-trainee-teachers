# frozen_string_literal: true

module FormStores
  module SystemAdmin
    class SchoolFormStore
      include Cacheable

      FORM_SECTION_KEYS = %i[
        school
      ].freeze
    end
  end
end
