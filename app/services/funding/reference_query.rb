# frozen_string_literal: true

module Funding
  # Read-only queries over the funding reference data (FundingMethod +
  # FundingMethodSubject + AllocationSubject) for a single academic cycle.
  # This is the browse/report data source for the Funding management admin area;
  # it never writes.
  class ReferenceQuery
    FUNDING_TYPES = %w[bursary scholarship grant].freeze

    def initialize(academic_cycle)
      @academic_cycle = academic_cycle
    end

    attr_reader :academic_cycle

    # Every entry across all funded academic cycles, newest year first, for the
    # unscoped (all-years) list. Each row still carries its own year and IFR id.
    def self.all_entries
      AcademicCycle.joins(:funding_methods).distinct.order(start_date: :desc).flat_map do |cycle|
        new(cycle).entries
      end
    end

    # One row per training route that has any funding in the cycle. A route can
    # carry several bands of the same funding type (e.g. £29k / £20k / £5k
    # bursaries by subject), so each type maps to a list of distinct amounts.
    def requirements
      methods = scoped_methods.to_a
      methods.map(&:training_route).uniq.sort.map do |training_route|
        route_methods = methods.select { |m| m.training_route == training_route }
        {
          training_route: training_route,
          amounts: FUNDING_TYPES.index_with do |funding_type|
            route_methods.select { |m| m.funding_type == funding_type }.filter_map(&:amount).uniq.sort.reverse
          end,
        }
      end
    end

    # One row per FundingMethod × attached subject in the cycle, ordered by the
    # IFR reference number then subject. This is the flat "Funding entries"
    # landing list. Each row carries the record's stored IFR reference, funding
    # method (HESA burslev) and degree relevance.
    def entries
      scoped_methods.includes(:allocation_subjects).sort_by { |m| m.reference_number || Float::INFINITY }.flat_map do |method|
        method.allocation_subjects.sort_by(&:name).map do |subject|
          {
            entry_id: method.reference,
            funding_method_id: method.id,
            academic_year: academic_cycle.label,
            academic_year_start: academic_cycle.start_year,
            funding_method: method.funding_method,
            funding_type: method.funding_type,
            training_route: method.training_route,
            subject: subject.name,
            subject_id: subject.id,
            degree_relevance: method.degree_relevance,
            school_disadvantage: method.school_disadvantage,
            training_year: method.training_year,
            amount: method.amount,
            availability: method.availability,
          }
        end
      end
    end

    # Entries for a single subject in the cycle — the same shape as #entries
    # (one row per FundingMethod attached to the subject) plus the change vs the
    # previous cycle for the route + type + subject.
    def subject_entries(allocation_subject)
      scoped_methods
        .joins(:allocation_subjects)
        .where(allocation_subjects: { id: allocation_subject.id })
        .sort_by { |method| method.reference_number || Float::INFINITY }
        .map do |method|
          previous = previous_amount_index[[method.training_route, method.funding_type, allocation_subject.name]]
          {
            entry_id: method.reference,
            funding_method_id: method.id,
            academic_year: academic_cycle.label,
            academic_year_start: academic_cycle.start_year,
            funding_method: method.funding_method,
            funding_type: method.funding_type,
            training_route: method.training_route,
            subject: allocation_subject.name,
            subject_id: allocation_subject.id,
            degree_relevance: method.degree_relevance,
            school_disadvantage: method.school_disadvantage,
            training_year: method.training_year,
            amount: method.amount,
            availability: method.availability,
            previous_amount: previous,
            change: change_for(method.amount, previous),
          }
        end
    end

    # The funding methods (bands) for one route, ordered by type then amount.
    def route_bands(training_route)
      scoped_methods
        .where(training_route:)
        .includes(:allocation_subjects)
        .to_a
        .sort_by { |m| [FUNDING_TYPES.index(m.funding_type) || FUNDING_TYPES.length, -(m.amount || 0)] }
    end

    def route_funded?(training_route)
      scoped_methods.exists?(training_route:)
    end

    # Funding bands for one subject across all routes/types in the cycle, with
    # the change vs the previous cycle.
    def subject_bands(allocation_subject)
      scoped_methods
        .joins(:allocation_subjects)
        .where(allocation_subjects: { id: allocation_subject.id })
        .to_a
        .sort_by { |m| [m.training_route, FUNDING_TYPES.index(m.funding_type) || FUNDING_TYPES.length, -(m.amount || 0)] }
        .map do |method|
          previous = previous_amount_index[[method.training_route, method.funding_type, allocation_subject.name]]
          {
            training_route: method.training_route,
            funding_type: method.funding_type,
            amount: method.amount,
            availability: method.availability,
            previous_amount: previous,
            change: change_for(method.amount, previous),
          }
        end
    end

    def subject_funded?(allocation_subject)
      scoped_methods.joins(:allocation_subjects).exists?(allocation_subjects: { id: allocation_subject.id })
    end

    # subject -> [{training_route, funding_type, amount, previous_amount, change}],
    # flat and sorted. `change` compares the amount to the same route + funding
    # type + subject in the previous academic cycle.
    def subject_records
      rows = []
      scoped_methods.includes(:allocation_subjects).find_each do |method|
        method.allocation_subjects.each do |subject|
          previous = previous_amount_index[[method.training_route, method.funding_type, subject.name]]
          rows << {
            subject: subject.name,
            subject_id: subject.id,
            training_route: method.training_route,
            funding_type: method.funding_type,
            amount: method.amount,
            availability: method.availability,
            previous_amount: previous,
            change: change_for(method.amount, previous),
          }
        end
      end
      rows.sort_by { |r| [r[:subject].downcase, r[:training_route], FUNDING_TYPES.index(r[:funding_type]) || 9] }
    end

    # The academic cycle immediately before the one being viewed, if any.
    def previous_cycle
      @previous_cycle ||= AcademicCycle.where(start_date: ...academic_cycle.start_date).order(start_date: :desc).first
    end

    def route_count
      scoped_methods.distinct.count(:training_route)
    end

    def subject_count
      scoped_methods.joins(:allocation_subjects).distinct.count("allocation_subjects.id")
    end

  private

    def scoped_methods
      academic_cycle.funding_methods
    end

    # [training_route, funding_type, subject_name] => amount, for the previous cycle.
    def previous_amount_index
      @previous_amount_index ||= begin
        index = {}
        previous_cycle&.funding_methods&.includes(:allocation_subjects)&.find_each do |method|
          method.allocation_subjects.each do |subject|
            index[[method.training_route, method.funding_type, subject.name]] = method.amount
          end
        end
        index
      end
    end

    def change_for(amount, previous_amount)
      return :not_available if amount.nil?
      return :new if previous_amount.nil?
      return :increase if amount > previous_amount
      return :decrease if amount < previous_amount

      :no_change
    end
  end
end
