# frozen_string_literal: true

module MissingFieldsCheckable
  extend ActiveSupport::Concern

  included do
    helper_method :missing_fields
  end

private

  def missing_fields
    @missing_fields ||= Submissions::MissingDataValidator.new(trainee:).missing_fields
  end
end
