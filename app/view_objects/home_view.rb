# frozen_string_literal: true

class HomeView
  def initialize(trainees)
    @trainees = Trainees::Filter.call(trainees: trainees, filters: {})
    populate_current_state_counts!
  end

  attr_reader :current_state_counts

  def registered_trainees_count
    @registered_trainees_count ||= trainees.not_draft.count
  end

  def future_registered_trainees_count
    @future_registered_trainees_count ||= trainees.not_draft.future.count
  end

  def current_registered_trainees_count
    @current_registered_trainees_count ||= current_state_counts.except("draft").values.sum
  end

  def draft_trainees_count
    @draft_trainees_count ||= trainees.draft.count
  end

  def draft_apply_trainees_count
    trainees.draft.with_apply_application.count
  end

private

  attr_reader :trainees

  def populate_current_state_counts!
    defaults = Trainee.states.keys.index_with { 0 }
    counts = trainees.current.group(:state).count.reverse_merge(defaults)

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

    @current_state_counts = counts
  end

  def eyts_trainees?
    @eyts_trainees ||= trainees.with_award_states("eyts_recommended", "eyts_awarded").count.positive?
  end

  def qts_trainees?
    @qts_trainees ||= trainees.with_award_states("qts_recommended", "qts_awarded").count.positive?
  end
end
