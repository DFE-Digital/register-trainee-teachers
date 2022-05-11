# frozen_string_literal: true

module Funding
  class PayableNotFoundError < StandardError; end

  class PayableTraineeSummariesImporter
    include ServicePattern

    def initialize(attributes:)
      @attributes = attributes
    end

    def call
      attributes.each_key do |id|
        payable = payable(id)

        raise(PayableNotFoundError, "payable with id: #{id} doesn't exist") if payable.nil?

        academic_year = attributes.values.flatten.first[academic_year_column]
        summary = payable.funding_trainee_summaries.create(academic_year: academic_year)

        attributes[id].each do |row_hash|
          row = summary.rows.create(
            subject: row_hash["Subject"],
            route: row_hash[route_column],
            lead_school_name: row_hash[lead_school_name_column],
            lead_school_urn: row_hash[lead_school_urn_column],
            cohort_level: row_hash["Cohort Level"],
          )

          amount_maps.each do |amount_map|
            number_of_trainees = row_hash[amount_map[:number_of_trainees]]
            amount_in_pence = row_hash[amount_map[:amount]].to_d * 100

            next unless number_of_trainees.to_d.positive? && amount_in_pence.to_d.positive?

            row.amounts.create(
              amount: amount_in_pence,
              number_of_trainees: number_of_trainees,
              payment_type: amount_map[:payment_type],
              tier: amount_map[:tier],
            )
          end
        end
      end
    end

    def payable(_id)
      raise(NotImplementedException("implement a payable method"))
    end

    def academic_year_column
      raise(NotImplementedException("implement a academic_year_column method"))
    end

    def route_column
      raise(NotImplementedException("implement a route_column method"))
    end

    def lead_school_name_column
      raise(NotImplementedException("implement a lead_school_name_column method"))
    end

    def lead_school_urn_column
      raise(NotImplementedException("implement a lead_school_urn_column method"))
    end

  private

    attr_reader :attributes
  end
end
