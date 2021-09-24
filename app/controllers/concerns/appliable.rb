# frozen_string_literal: true

module Appliable
  def draft_apply_application?
    trainee.apply_application? && trainee.draft?
  end
end
