# frozen_string_literal: true

module Funding
  # Read-only access to the Common Aggregation Hierarchy (CAH) and its HECoS
  # mapping from the dfe-reference-data gem, shaped for the Relevant degree CAH
  # management screens: CAH level 1 → level 2 → the HECoS codes underneath.
  class CahReference
    CAH = DfE::ReferenceData::CommonAggregationHierarchy

    class << self
      # [[code, name], …] sorted by code — the CAH level 1 options.
      def level_1_options
        CAH::CAH_CATEGORIES_L1.all.map { |l1| [l1.id, titleize(l1.name)] }.sort_by(&:first)
      end

      # [[code, name], …] — the CAH level 2 children of a level 1 code.
      def level_2_options(level_1_code)
        return [] if level_1_code.blank?

        l1 = CAH::CAH_CATEGORIES_L1.one(level_1_code)
        return [] if l1.nil?

        l1.l2_children.filter_map { |l2_id| l2 = CAH::CAH_CATEGORIES_L2.one(l2_id); [l2.id, titleize(l2.name)] if l2 }
      end

      # [[hecos_code, "Name (code)"], …] — the HECoS codes that sit under a CAH
      # level 2 (via its level 3 children), with names from the degrees reference.
      def hecos_options(level_2_code)
        hecos_codes_for(level_2_code).map { |code| [code, "#{hecos_name(code)} (#{code})"] }.sort_by { |_c, label| label }
      end

      def hecos_codes_for(level_2_code)
        return [] if level_2_code.blank?

        l2 = CAH::CAH_CATEGORIES_L2.one(level_2_code)
        return [] if l2.nil?

        l3_ids = l2.l3_children
        CAH::HECOS_CAH_SUBJECT_MAPPINGS.all.select { |m| l3_ids.include?(m.cah_l3_id) }.map(&:id)
      end

      def level_1_name(code)
        l1 = CAH::CAH_CATEGORIES_L1.one(code) if code.present?
        l1 ? titleize(l1.name) : code
      end

      def level_2_name(code)
        l2 = CAH::CAH_CATEGORIES_L2.one(code) if code.present?
        l2 ? titleize(l2.name) : code
      end

      def hecos_name(code)
        hecos_names[code] || code
      end

      def valid_level_1?(code) = level_1_options.any? { |c, _| c == code }
      def valid_level_2?(level_1_code, code) = level_2_options(level_1_code).any? { |c, _| c == code }

    private

      def hecos_names
        @hecos_names ||= DfEReference::DegreesQuery::SUBJECTS.all.each_with_object({}) do |subject, hash|
          code = subject.try(:hecos_code)
          hash[code] = subject.name if code.present?
        end
      end

      def titleize(name) = name.to_s.split.map(&:capitalize).join(" ")
    end
  end
end
