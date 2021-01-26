# frozen_string_literal: true

module Breadcrumbable
  def save_origin_page_for(trainee)
    OriginPage.new(trainee, session, request).save
  end
end
