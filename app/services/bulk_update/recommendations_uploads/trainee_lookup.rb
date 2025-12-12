# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class TraineeLookup
      include Config

      def initialize(rows, provider)
        @rows = rows
        @scope = provider
          .trainees
          .kept
          .where.not(state: :draft)
          .includes(
            :training_partner,
            :provider,
            :degrees,
            :apply_application,
            :course_allocation_subject,
            :start_academic_cycle,
            :disabilities,
          )
      end

      def [](key)
        case key
        when VALID_TRN
          trainees_trn_map.fetch(key, [])
        when VALID_HESA_ID
          trainees_hesa_id_map.fetch(key, [])
        else
          trainees_trainee_id_map.fetch(key, [])
        end
      end

    private

      attr_reader :rows, :scope

      # Only build the appropriate hash maps when needed

      def trainees_trn_map
        @trainees_trn_map ||= build_trainee_hash_map(:trn)
      end

      def trainees_hesa_id_map
        @trainees_hesa_id_map ||= build_trainee_hash_map(:hesa_id)
      end

      def trainees_trainee_id_map
        @trainees_trainee_id_map ||= build_trainee_hash_map(:provider_trainee_id)
      end

      def build_trainee_hash_map(key)
        scope.where(key => rows.map(&row_attribute(key))).inject({}) do |hash, trainee|
          hash[trainee[key]] ||= []
          hash[trainee[key]] << trainee
          hash
        end
      end

      def row_attribute(lookup_key)
        case lookup_key
        when :hesa_id then :sanitised_hesa_id
        else lookup_key
        end
      end
    end
  end
end
