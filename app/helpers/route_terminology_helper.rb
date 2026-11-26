# frozen_string_literal: true

# The EYTDA wording in views (RouteTerminology).
module RouteTerminologyHelper
  def route_t(trainee, key, **)
    RouteTerminology.t(trainee, key, **)
  end
end
