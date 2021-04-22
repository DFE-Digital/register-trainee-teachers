# frozen_string_literal: true

module SchoolHelper
  def school_urn_and_location(school)
    [school.urn, school.town, school.postcode].join(", ")
  end
end
