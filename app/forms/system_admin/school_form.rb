# frozen_string_literal: true

module SystemAdmin
  class SchoolForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :lead_partner, :boolean

    delegate :name, :urn, :town, :postcode, :open_date, :close_date, to: :school

    validates :lead_partner, inclusion: [true, false]

    def initialize(school, params: {}, store: FormStores::SystemAdmin::SchoolFormStore)
      @school = school
      @params = params
      @store  = store

      super(
        compute_attributes.reverse_merge(
          lead_partner: school.lead_school
        )
      )
    end

    def stash
      return false unless valid?

      store.set(school.id, :system_admin_school, attributes)
    end

    def save
      return false unless valid?

      ApplicationRecord.transaction do
        if lead_partner
          find_or_create_lead_partner.tap do |school_lead_partner|
            school_lead_partner.undiscard! if school_lead_partner.discarded?
          end
        else
          school.lead_partner&.discard!
        end

        school.attributes = school_attributes
        school.save!
      end
    end

    def clear_stash
      store.clear_all(school.id)
    end

    def lead_partner_options
      [true, false].map do |value|
        OpenStruct.new(id: value, name: value == true ? "Yes" : "No")
      end
    end

    private

    attr_reader :school, :params, :store

    def school_attributes
      {
        lead_school: lead_partner
      }
    end

    def find_or_create_lead_partner
      LeadPartner.find_or_create_by!(school_id: school.id, urn: school.urn) do |lp|
        lp.name        = school.name
        lp.record_type = LeadPartner::LEAD_SCHOOL
      end
    end

    def compute_attributes
      @compute_attributes ||= (
        attributes_from_store ? params.reverse_merge(attributes_from_store) : params
      ).to_h.with_indifferent_access
    end

    def attributes_from_store
      store.get(school.id, :system_admin_school)
    end
  end
end
