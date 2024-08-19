# frozen_string_literal: true

module FormStores
  module SystemAdmin
    class SchoolFormStore
      include Cacheable

      FORM_SECTION_KEYS = %i[
        system_admin_school
      ].freeze
    end
  end
end
