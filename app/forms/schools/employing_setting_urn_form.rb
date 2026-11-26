# frozen_string_literal: true

module Schools
  # Early years teacher degree apprenticeship: whether the apprentice employing
  # setting has a URN. Yes searches Get information about schools (GIAS); no types
  # the setting in. The answer isn't saved: it's worked out from the setting.
  class EmployingSettingUrnForm
    include ActiveModel::Model

    ANSWERS = %w[yes no].freeze

    attr_accessor :trainee, :has_urn

    validates :has_urn, inclusion: { in: ANSWERS }

    # The answer the trainee's setting gives: found in the search, or typed in.
    def self.for(trainee)
      has_urn = if trainee.employing_school_id.present?
                  "yes"
                elsif trainee.employing_school_name.present?
                  "no"
                end
      new(trainee:, has_urn:)
    end

    def urn?
      has_urn == "yes"
    end
  end
end
