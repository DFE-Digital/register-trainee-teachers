# frozen_string_literal: true

class HomeView
  REGISTERED_STATES_FOR_FILTER = %w[submitted_for_trn trn_received qts_recommended
                                    eyts_recommended withdrawn deferred qts_awarded
                                    eyts_awarded].freeze

  def initialize(trainees)
    @trainees = Trainees::Filter.call(trainees: trainees, filters: {})
    populate_state_counts!
  end

  attr_reader :state_counts

  def registered_state_counts
    @registered_state_counts ||= state_counts.except("draft")
  end

  def registered_trainees_count
    @registered_trainees_count ||= registered_state_counts.values.sum
  end

  def draft_trainees_count
    @draft_trainees_count ||= state_counts["draft"]
  end

  def draft_apply_trainees_count
    trainees.draft.with_apply_application.count
  end

private

  attr_reader :trainees

  def populate_state_counts!
    defaults = Trainee.states.keys.index_with { 0 }
    counts = trainees.group(:state).count.reverse_merge(defaults)

    if eyts_trainees? == qts_trainees?
      counts["awarded"] ||= 0
      counts["recommended_for_award"] ||= 0
    elsif eyts_trainees?
      awarded = counts.delete("awarded")
      counts["eyts_awarded"] = awarded

      recommended = counts.delete("recommended_for_award")
      counts["eyts_recommended"] = recommended
    elsif qts_trainees?
      awarded = counts.delete("awarded")
      counts["qts_awarded"] = awarded

      recommended = counts.delete("recommended_for_award")
      counts["qts_recommended"] = recommended
    end

    @state_counts = counts
  end

  def eyts_trainees?
    @eyts_trainees ||= trainees.with_award_states("eyts_recommended", "eyts_awarded").count.positive?
  end

  def qts_trainees?
    @qts_trainees ||= trainees.with_award_states("qts_recommended", "qts_awarded").count.positive?
  end
end
