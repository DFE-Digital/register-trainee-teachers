# frozen_string_literal: true

module Funding
  class TraineeSummaryView
    include ActionView::Helpers

    PaymentTypeSummary = Struct.new(:title, :summary_data, keyword_init: true) do
      def total
        summary_data.map(&:total).sum
      end
    end

    PaymentTypeSummaryRow = Struct.new(:payment_type, :total, keyword_init: true)

    def initialize(trainee_summary:)
      @trainee_summary = trainee_summary
    end

    def summary
      PaymentTypeSummary.new(title: "Summary", summary_data: summary_data)
    end

    def summary_data
      [
        PaymentTypeSummaryRow.new(payment_type: "ITT bursaries", total: payment_type_total(data_for_bursaries)),
        PaymentTypeSummaryRow.new(payment_type: "ITT scholarships", total: payment_type_total(data_for_scholarships)),
        PaymentTypeSummaryRow.new(payment_type: "Early years ITT bursaries", total: payment_type_total(data_for_tiered_bursaries)),
        PaymentTypeSummaryRow.new(payment_type: "Grants", total: payment_type_total(data_for_grants)),
      ]
    end

    def last_updated_at
      trainee_summary.created_at.strftime("%d %B %Y")
    end

    def empty?
      return true if trainee_summary.nil? || trainee_summary.rows.empty?

      trainee_summary.rows.none? { |row| row.amounts.any? }
    end

    def bursary_breakdown_rows
      sort_by_route_then_subject(data_for_bursaries).map do |amount|
        total_amount = amount.number_of_trainees * amount.amount_in_pence
        { route: amount.row.route,
          subject: amount.row.subject,
          training_partner: format_training_partner_string(amount),
          trainees: amount.number_of_trainees,
          amount_per_trainee: format_pounds(amount.amount_in_pence),
          total: format_pounds(total_amount) }
      end
    end

    def scholarship_breakdown_rows
      sort_by_route_then_subject(data_for_scholarships).map do |amount|
        total_amount = amount.number_of_trainees * amount.amount_in_pence
        { route: amount.row.route,
          subject: amount.row.subject,
          training_partner: format_training_partner_string(amount),
          trainees: amount.number_of_trainees,
          amount_per_trainee: format_pounds(amount.amount_in_pence),
          total: format_pounds(total_amount) }
      end
    end

    def tiered_bursary_breakdown_rows
      sort_by_route_then_tier(data_for_tiered_bursaries).map do |amount|
        total_amount = amount.number_of_trainees * amount.amount_in_pence
        { route: amount.row.route,
          tier: "Tier #{amount.tier}",
          trainees: amount.number_of_trainees,
          amount_per_trainee: format_pounds(amount.amount_in_pence),
          total: format_pounds(total_amount) }
      end
    end

    def grant_breakdown_rows
      sort_by_route_then_subject(data_for_grants).map do |amount|
        total_amount = amount.number_of_trainees * amount.amount_in_pence
        { route: amount.row.route,
          subject: amount.row.subject,
          trainees: amount.number_of_trainees,
          amount_per_trainee: format_pounds(amount.amount_in_pence),
          total: format_pounds(total_amount) }
      end
    end

    def format_pounds(amount)
      return "—" if amount.zero?

      number_to_currency(amount.to_d / 100, unit: "£").gsub(/\.00$/, "")
    end

  private

    attr_reader :trainee_summary

    def payment_type_total(data_for_payment_type)
      data_for_payment_type.map { |data| (data.amount_in_pence * data.number_of_trainees) }.sum
    end

    def sort_by_route_then_subject(data)
      Array(data.sort_by { |amount| [amount.row.route, amount.row.subject] })
    end

    def sort_by_route_then_tier(data)
      Array(data.sort_by { |amount| [amount.row.route, amount.tier] })
    end

    def data_for_scholarships
      trainee_summary.rows.filter_map { |row| get_scholarship_amounts(row) }.flatten
    end

    def data_for_bursaries
      trainee_summary.rows.filter_map { |row| get_bursary_amounts(row) }.flatten
    end

    def data_for_tiered_bursaries
      trainee_summary.rows.filter_map { |row| get_tiered_bursary_amounts(row) }.flatten
    end

    def data_for_grants
      trainee_summary.rows.filter_map { |row| get_grant_amounts(row) }.flatten
    end

    def get_scholarship_amounts(row)
      row.amounts.select(&:scholarship?)
    end

    def get_bursary_amounts(row)
      row.amounts.select(&:untiered_bursary?)
    end

    def get_tiered_bursary_amounts(row)
      row.amounts.select(&:tiered_bursary?)
    end

    def get_grant_amounts(row)
      row.amounts.select(&:grant?)
    end

    def format_training_partner_string(amount)
      return "—" if amount.row.lead_school_name.nil?

      amount.row.lead_school_name
    end
  end
end
