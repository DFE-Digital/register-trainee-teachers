# frozen_string_literal: true

module NotifyOnTimeout
  def notify_on_timeout(trainee, class_name)
    TeamsNotifierService.call(
      title: "#{class_name} timed out",
      message: "#{class_name} for Trainee with slug: #{trainee.slug} has timed out after #{Settings.jobs.max_poll_duration_days} days.",
      icon_emoji: "⏳",
    )
  end
end
