# frozen_string_literal: true

module SystemAdmin
  class SchoolForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    LEAD_PARTNER_OPTION = Struct.new(:id, :name)

    private_constant :LEAD_PARTNER_OPTION

    attribute :lead_partner, :boolean
    alias lead_partner? lead_partner

    delegate :name,
             :urn,
             :town,
             :postcode,
             :open_date,
             :close_date,
             :to_param, to: :school

    attr_reader :school

    validates :lead_partner, inclusion: [true, false]

    def self.model_name
      ActiveModel::Name.new(School)
    end

    def initialize(school, params: {}, store: FormStores::SystemAdmin::SchoolFormStore)
      @school = school
      @params = params
      @store  = store

      super(
        compute_attributes.reverse_merge(
          lead_partner: school.lead_partner?,
        )
      )
    end

    def stash
      return false unless valid?

      store.set(school.id, :system_admin_school, attributes)
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        if lead_partner
          find_or_create_lead_partner!.tap do |school_lead_partner|
            school_lead_partner.undiscard! if school_lead_partner.discarded?
          end
        elsif school.lead_partner&.undiscarded?
          school.lead_partner.discard!
        end

        school.save!
      end
    end

    def clear_stash
      store.clear_all(school.id)
    end

    def lead_partner_options
      [true, false].map do |value|
        LEAD_PARTNER_OPTION.new(id: value, name: value ? "Yes" : "No")
      end
    end

  private

    attr_reader :params, :store

    def find_or_create_lead_partner!
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
