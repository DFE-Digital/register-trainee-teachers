# frozen_string_literal: true

class HomeView
  def initialize(trainees)
    @trainees = trainees
    populate_state_counts!
  end

  attr_reader :state_counts

private

  def populate_state_counts!
    defaults = Trainee.states.keys.index_with { 0 }
    counts = @trainees.group(:state).count.reverse_merge(defaults)

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
    return @_eyts_trainees if defined?(@_eyts_trainees)

    @_eyts_trainees = @trainees.with_award_states("eyts_recommended", "eyts_awarded").count.positive?
  end

  def qts_trainees?
    return @_qts_trainees if defined?(@_qts_trainees)

    @_qts_trainees = @trainees.with_award_states("qts_recommended", "qts_awarded").count.positive?
  end
end
