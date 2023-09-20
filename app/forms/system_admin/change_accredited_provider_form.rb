# frozen_string_literal: true

module SystemAdmin
  class ChangeAccreditedProviderForm < TraineeForm
    FIELDS = %i[
      accredited_provider_id
      audit_comment
      zendesk_ticket_url
    ].freeze

    attr_accessor(*FIELDS)

    validates :accredited_provider_id, presence: true, on: :provider
    #
    # TODO: This doesn't work because the validations are not scoped in the
    # form base class (they don't use the `on`) and this attribute is only
    # required from the reasons page onwards.
    #
    # validates :audit_comment, presence: true, on: :reasons

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
      "#{I18n.t("components.timeline.titles.trainee.accredited_provider_change")}: #{audit_comment} #{zendesk_ticket_url}"
    end
  end
end
