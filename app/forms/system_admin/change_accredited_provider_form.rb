# frozen_string_literal: true

module SystemAdmin
  class ChangeAccreditedProviderForm < TraineeForm
    FIELDS = %i[
      accredited_provider_id
      audit_comment
      zendesk_ticket_url
    ].freeze

    attr_accessor(*FIELDS)
    attr_accessor :step

    validates :accredited_provider_id, presence: true, if: -> { !step || step == :provider }
    validates :audit_comment, presence: true, if: -> { !step || step == :reasons }

    def initialize(trainee, params: {}, user: nil, store: FormStore, step: nil)
      self.step = step
      super(trainee, params:, user:, store:)
    end

    def save!
      return false unless valid?

      Trainees::Update.call(
        trainee: trainee,
        params: {
          provider_id: accredited_provider_id,
          audit_comment: build_audit_comment,
        },
      )

      clear_stash
    end

    def accredited_provider_name
      Provider.find(accredited_provider_id)&.name_and_code
    end

    delegate :full_name, :id, to: :trainee

  private

    def compute_fields
      { accredited_provider_id: trainee.provider_id }.merge(new_attributes)
    end

    def form_store_key
      :change_accredited_provider
    end

    def build_audit_comment
      [audit_comment, zendesk_ticket_url].compact.join(" ")
    end
  end
end
