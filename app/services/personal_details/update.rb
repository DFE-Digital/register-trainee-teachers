module PersonalDetails
  class Update
    attr_reader :trainee, :personal_detail, :successful

    alias_method :successful?, :successful

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def initialize(trainee:, attributes: {})
      @trainee = trainee
      trainee.assign_attributes(normalize_attributes(attributes))
      @personal_detail = PersonalDetail.new(trainee: trainee)
    end

    def call
      @successful = personal_detail.valid? && trainee.save!
      self
    end

  private

    def normalize_attributes(attributes)
      return completed_attributes(attributes) if attributes[:mark_as_completed].present?

      attributes
    end

    def completed_attributes(attributes)
      { progress: { personal_detail: ActiveModel::Type::Boolean.new.cast(attributes[:mark_as_completed]) } }
    end
  end
end
