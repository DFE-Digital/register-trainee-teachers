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

      trainee.update!(
        provider_id: accredited_provider_id,
        audit_comment: build_audit_comment,
      )

      clear_stash
    end

    def accredited_provider_name
      Provider.find(accredited_provider_id)&.name_and_code
    end

    delegate :full_name, :id, to: :trainee

  private

    def compute_fields
      new_attributes
    end

    def form_store_key
      :change_accredited_provider
    end

    def build_audit_comment
      "#{I18n.t('components.timeline.titles.trainee.accredited_provider_change')}: #{audit_comment} #{zendesk_ticket_url}"
    end
  end
end
